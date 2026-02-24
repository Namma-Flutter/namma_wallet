# GitHub Pages Deployment Setup

This guide explains how to complete the setup for automatic deployment to GitHub Pages.

> **Note**: This guide describes CI/CD automation behavior. For local development commands, always use `fvm flutter` instead of `flutter` as documented in SETUP.md.

## What's Already Done

✅ Created `.github/workflows/deploy_github_pages.yml` workflow file
✅ Configured automatic deployment on every branch push
✅ Added manual deployment trigger option
✅ Added branch preview deployments at `/previews/<branch>/`

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
3. Under **Build and deployment**, select:
   - **Source**: `Deploy from a branch`
   - **Branch**: `gh-pages`
   - **Folder**: `/ (root)`
4. Click **Save**

### 3. Trigger the First Deployment

The workflow will automatically run on the next push to any branch. You can also:

- **Manually trigger**: Go to **Actions** tab → **Deploy to GitHub Pages** → **Run workflow**
- **Wait for automatic trigger**: Push any change to `main` branch

### 4. Access Your Deployed Site

After successful deployment, your site will be available at:

```text
https://<your-github-username>.github.io/<repository-name>/
```

For example: `https://yourusername.github.io/namma_wallet/`

Branch previews are available at:

```text
https://<your-github-username>.github.io/<repository-name>/previews/<branch-slug>/
```

Example:
`https://yourusername.github.io/namma_wallet/previews/bugfix-web-not-working/`

## How It Works

The workflow:

1. **Builds** the Flutter web app using `flutter build web --release --wasm`
2. **Compiles** to WebAssembly (WASM) for improved performance and faster load times
3. **Configures** the base href for GitHub Pages subdirectory hosting
4. **Publishes** main branch to `/` on `gh-pages`
5. **Publishes** non-main branches to `/previews/<branch-slug>/` on `gh-pages`
6. **Keeps** existing preview folders so branch deploys do not overwrite each other

### Why WASM?

WebAssembly provides:

- **Better performance**: Faster execution compared to JavaScript
- **Smaller bundle size**: More efficient code representation
- **Improved startup time**: Faster initial app load

## Customization

### Branch Routing

- `main` deploys to root: `/`
- all other branches deploy to: `/previews/<branch-slug>/`

### Manual Deployment Only

To disable automatic deployment on push, remove lines 3-5 and keep only `workflow_dispatch`.

## Troubleshooting

### Build Fails

- Check Flutter version compatibility (currently set to 3.35.2)
- Ensure all dependencies in `pubspec.yaml` support web platform and WASM
- Review build logs in GitHub Actions tab for WASM-specific errors

### Pages Not Found (404)

- Verify GitHub Pages is enabled with **Source: Deploy from a branch**
- Verify branch is set to **gh-pages** and folder is **/(root)**
- Check that the base href is correctly set
- Ensure the workflow completed successfully

### Permission Issues

The workflow includes necessary permissions:

- `contents: write` - to push built files to the `gh-pages` branch

If issues persist, verify repository settings allow GitHub Actions.

## Next Steps

1. Push the workflow file to GitHub
2. Enable GitHub Pages in repository settings
3. Wait for the first successful deployment
4. Visit your live site!

---

**Note**: The first deployment might take 2-5 minutes. Subsequent deployments are usually faster due to caching.
