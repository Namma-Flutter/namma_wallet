# GitHub Pages Deployment Setup

This guide explains how to complete the setup for automatic deployment to GitHub Pages.

## What's Already Done

✅ Created `.github/workflows/deploy_github_pages.yml` workflow file
✅ Configured automatic deployment on every push to `main` branch
✅ Added manual deployment trigger option

## Steps to Enable GitHub Pages

### 1. Push the Workflow to GitHub

```bash
git add .github/workflows/deploy_github_pages.yml
git commit -m "feat: add GitHub Pages auto-deployment workflow"
git push origin main
```

### 2. Enable GitHub Pages in Repository Settings

1. Go to your repository on GitHub
2. Click **Settings** → **Pages** (in the left sidebar)
3. Under **Source**, select:
   - **Source**: `GitHub Actions`
4. Click **Save**

### 3. Trigger the First Deployment

The workflow will automatically run on the next push to `main`. You can also:

- **Manually trigger**: Go to **Actions** tab → **Deploy to GitHub Pages** → **Run workflow**
- **Wait for automatic trigger**: Push any change to `main` branch

### 4. Access Your Deployed Site

After successful deployment, your site will be available at:

```text
https://<your-github-username>.github.io/<repository-name>/
```

For example: `https://yourusername.github.io/namma_wallet/`

## How It Works

The workflow:

1. **Builds** the Flutter web app using `flutter build web --release --wasm`
2. **Compiles** to WebAssembly (WASM) for improved performance and faster load times
3. **Configures** the base href for GitHub Pages subdirectory hosting
4. **Uploads** the build artifacts from `build/web`
5. **Deploys** to GitHub Pages automatically

### Why WASM?

WebAssembly provides:

- **Better performance**: Faster execution compared to JavaScript
- **Smaller bundle size**: More efficient code representation
- **Improved startup time**: Faster initial app load

## Customization

### Change Trigger Branch

If your default branch is not `main`, edit line 5 in the workflow file:

```yaml
branches:
  - main  # Change to your branch name (e.g., master, develop)
```

### Manual Deployment Only

To disable automatic deployment on push, remove lines 3-5 and keep only `workflow_dispatch`.

## Troubleshooting

### Build Fails

- Check Flutter version compatibility (currently set to 3.35.2)
- Ensure all dependencies in `pubspec.yaml` support web platform and WASM
- Review build logs in GitHub Actions tab for WASM-specific errors

### Pages Not Found (404)

- Verify GitHub Pages is enabled with **Source: GitHub Actions**
- Check that the base href is correctly set
- Ensure the workflow completed successfully

### Permission Issues

The workflow includes necessary permissions:

- `contents: read` - to checkout code
- `pages: write` - to deploy to Pages
- `id-token: write` - for authentication

If issues persist, verify repository settings allow GitHub Actions.

## Next Steps

1. Push the workflow file to GitHub
2. Enable GitHub Pages in repository settings
3. Wait for the first successful deployment
4. Visit your live site!

---

**Note**: The first deployment might take 2-5 minutes. Subsequent deployments are usually faster due to caching.
