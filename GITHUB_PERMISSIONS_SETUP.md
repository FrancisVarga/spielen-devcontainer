# GitHub Permissions Setup for Release Please

## Issue
Release-please is failing with: "GitHub Actions is not permitted to create or approve pull requests."

## Root Cause
GitHub has security restrictions that prevent the default `GITHUB_TOKEN` from creating pull requests in many repository configurations.

## Solutions

### Option 1: Enable GitHub Actions to Create Pull Requests (Recommended)

1. **Go to Repository Settings:**
   - Navigate to your repository on GitHub
   - Click on "Settings" tab
   - Go to "Actions" → "General"

2. **Enable Pull Request Creation:**
   - Scroll down to "Workflow permissions"
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"
   - Click "Save"

### Option 2: Use Personal Access Token (Alternative)

If Option 1 doesn't work or isn't available:

1. **Create a Personal Access Token:**
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Give it a descriptive name like "Release Please Token"
   - Set expiration (recommend 1 year)
   - Select scopes:
     - `repo` (Full control of private repositories)
     - `workflow` (Update GitHub Action workflows)

2. **Add Token to Repository Secrets:**
   - Go to your repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `RELEASE_PLEASE_TOKEN`
   - Value: Your personal access token
   - Click "Add secret"

## Workflow Configuration

The workflow is already configured to use either approach:

```yaml
token: ${{ secrets.RELEASE_PLEASE_TOKEN || secrets.GITHUB_TOKEN }}
```

This will:
1. Use `RELEASE_PLEASE_TOKEN` if it exists (Option 2)
2. Fall back to `GITHUB_TOKEN` if repository permissions are properly configured (Option 1)

## Verification

After implementing either solution:

1. **Push a commit with conventional commit format:**
   ```bash
   git commit -m "fix: resolve container startup issue"
   git push origin main
   ```

2. **Check GitHub Actions:**
   - Go to Actions tab in your repository
   - Look for the "Release Please" workflow
   - It should run successfully and create a release PR

3. **Expected Behavior:**
   - Release-please creates a pull request with version bump and changelog
   - When you merge that PR, it creates a GitHub release
   - The Docker build and push workflow runs automatically

## Troubleshooting

### If Option 1 doesn't work:
- Your repository might be in an organization with stricter policies
- Use Option 2 (Personal Access Token)

### If Option 2 doesn't work:
- Verify the PAT has correct permissions
- Check that the secret name matches exactly: `RELEASE_PLEASE_TOKEN`
- Ensure the token hasn't expired

### If both fail:
- Check repository branch protection rules
- Verify you have admin access to the repository
- Consider using a GitHub App instead of PAT for organization repositories

## Security Considerations

- **Option 1** is more secure as it uses GitHub's built-in token
- **Option 2** requires managing a personal access token
- Both options are acceptable for most use cases
- For organization repositories, consider using GitHub Apps for better security

## Next Steps

1. Choose and implement one of the options above
2. Test with a conventional commit
3. Monitor the workflow execution
4. Merge the release PR when created to trigger Docker image publishing

The workflow will now properly create release pull requests and publish Docker images after successful container validation.
