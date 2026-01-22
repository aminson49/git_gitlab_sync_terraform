# Testing

Use these steps to confirm both directions work.

## 1) GitHub → GitLab (Jenkins)

1. Push a small change to GitHub:
   ```bash
   echo "test github to gitlab" > test-gh-to-gl.txt
   git add test-gh-to-gl.txt
   git commit -m "Test GitHub to GitLab"
   git push origin main
   ```
2. Jenkins job should run.
3. The file should appear in GitLab.

## 2) GitLab → GitHub (GitLab CI)

1. Push a small change to GitLab:
   ```bash
   echo "test gitlab to github" > test-gl-to-gh.txt
   git add test-gl-to-gh.txt
   git commit -m "Test GitLab to GitHub"
   git push origin main
   ```
2. GitLab pipeline should run.
3. The file should appear in GitHub.

## If something fails

- GitHub webhook deliveries (GitHub → Settings → Webhooks)
- Jenkins console output (job → Console Output)
- GitLab pipeline logs (CI/CD → Pipelines)

## Cleanup

```bash
git rm test-gh-to-gl.txt test-gl-to-gh.txt
git commit -m "Remove test files"
git push origin main
```
