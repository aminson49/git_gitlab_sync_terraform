stages:
  - sync

sync-to-github:
  stage: sync
  image: alpine:latest
  before_script:
    - apk add --no-cache git bash
    - git config --global user.email "ci@gitlab.com"
    - git config --global user.name "GitLab CI"
  script:
    - |
      if [ -z "$${GITHUB_TOKEN}" ]; then
        echo "Error: GITHUB_TOKEN not set"
        exit 1
      fi
      
      if git log -1 --pretty=%B | grep -q "\[skip sync\]"; then
        echo "Skipping sync - commit marked with [skip sync]"
        exit 0
      fi
      
      GITHUB_REPO_URL="$${GITHUB_REPO_URL:-${github_repo_url}}"
      
      if ! git remote | grep -q github; then
        git remote add github "$${GITHUB_REPO_URL}"
      else
        git remote set-url github "$${GITHUB_REPO_URL}"
      fi
      
      CURRENT_BRANCH="$${CI_COMMIT_REF_NAME#refs/heads/}"
      [ -z "$${CURRENT_BRANCH}" ] && CURRENT_BRANCH="$${CI_COMMIT_BRANCH}"
      
      git checkout -f $${CURRENT_BRANCH} || exit 1
      
      GITHUB_URL_WITH_TOKEN=$(echo "$${GITHUB_REPO_URL}" | sed "s|https://|https://$${GITHUB_TOKEN}@|")
      git remote set-url github "$${GITHUB_URL_WITH_TOKEN}"
      
      git fetch github 2>&1 || true
      
      if git push github $${CURRENT_BRANCH}:$${CURRENT_BRANCH} 2>&1; then
        echo "Synced $${CURRENT_BRANCH} to GitHub"
      else
        if git fetch github $${CURRENT_BRANCH} && git merge github/$${CURRENT_BRANCH} -X ours -m "Merge from GitHub - kept GitLab version [skip sync]"; then
          git push github $${CURRENT_BRANCH}:$${CURRENT_BRANCH} || exit 1
          echo "Synced after merge"
        else
          echo "Sync failed"
          exit 1
        fi
      fi
  rules:
    - if: $CI_COMMIT_BRANCH
      when: on_success
