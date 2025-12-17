# GitHub Workflows for Doorphone Viewer

This directory contains GitHub Actions workflows for the Doorphone Viewer Flutter application.

## Workflows

### 1. Build and Release Android APK (`build-android.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Tags starting with `v*`
- Pull requests to `main`
- Manual workflow dispatch

**Features:**
- Builds both debug and release APKs
- Creates Android App Bundle (AAB) for Play Store
- Runs Flutter analyzer and tests
- Uploads artifacts for download
- Creates GitHub releases for tagged versions
- Handles AWS certificate placeholders for CI builds

**Artifacts:**
- `doorphone-viewer-debug-apk`: Debug APK for testing
- `doorphone-viewer-release-apk`: Release APK for distribution
- `doorphone-viewer-release-aab`: App Bundle for Play Store

### 2. Continuous Integration (`ci.yml`)

**Triggers:**
- Push to any branch
- Pull requests to `main` or `develop`

**Features:**
- Code formatting verification
- Flutter analyzer
- Unit tests with coverage
- Security scanning with Trivy
- Dependency auditing
- Build verification without release

### 3. Release Management (`release.yml`)

**Triggers:**
- Manual workflow dispatch with version type selection

**Features:**
- Automated version bumping (patch/minor/major)
- Changelog generation from git commits
- Git tagging and pushing
- Documentation updates
- Triggers build workflow for new releases

## Setup Requirements

### Repository Secrets

Add these secrets to your GitHub repository:

1. **`GOOGLE_SERVICES_JSON`**: Your Firebase `google-services.json` content as a JSON string
2. **`GITHUB_TOKEN`**: Automatically provided by GitHub (no setup needed)

### Optional Secrets for Production

For production builds, you may want to add:

1. **`ANDROID_KEYSTORE`**: Base64 encoded Android keystore file
2. **`KEYSTORE_PASSWORD`**: Keystore password
3. **`KEY_ALIAS`**: Key alias
4. **`KEY_PASSWORD`**: Key password
5. **`AWS_CERTIFICATES`**: Base64 encoded AWS IoT certificates

## Usage

### Building APKs

1. **Automatic builds**: Push to `main` or `develop` branches
2. **Manual builds**: Go to Actions → "Build and Release Android APK" → "Run workflow"
3. **Release builds**: Create a tag starting with `v` (e.g., `v1.0.0`)

### Creating Releases

1. Go to Actions → "Release Management" → "Run workflow"
2. Select version bump type (patch/minor/major)
3. Choose whether to create a pre-release
4. The workflow will:
   - Update version numbers
   - Create git tag
   - Trigger build workflow
   - Create GitHub release

### Downloading APKs

1. Go to Actions → Select a completed workflow run
2. Scroll down to "Artifacts" section
3. Download the desired APK file

## File Structure

```
.github/
├── workflows/
│   ├── build-android.yml    # Main build and release workflow
│   ├── ci.yml              # Continuous integration
│   └── release.yml         # Release management
├── ISSUE_TEMPLATE/
│   ├── bug_report.md       # Bug report template
│   └── feature_request.md  # Feature request template
├── pull_request_template.md # PR template
├── CODEOWNERS             # Code ownership rules
└── README.md              # This file
```

## Customization

### Modifying Build Process

Edit `build-android.yml` to:
- Change Flutter version
- Add additional build steps
- Modify artifact naming
- Add deployment steps

### Adding New Workflows

Create new `.yml` files in `.github/workflows/` for:
- Automated testing on different devices
- Code quality checks
- Deployment to app stores
- Notification integrations

### Security Considerations

- Never commit sensitive data (certificates, keys) to the repository
- Use GitHub secrets for sensitive configuration
- Review and approve workflow changes carefully
- Monitor workflow runs for security issues

## Troubleshooting

### Common Issues

1. **Build fails with certificate errors**: Ensure placeholder certificates are created in CI
2. **Firebase configuration missing**: Add `GOOGLE_SERVICES_JSON` secret
3. **Version conflicts**: Check `pubspec.yaml` version format
4. **Permission errors**: Verify repository permissions and secrets

### Debug Steps

1. Check workflow logs in GitHub Actions
2. Verify all required secrets are set
3. Test builds locally with same Flutter version
4. Check for dependency conflicts

## Contributing

When contributing to workflows:

1. Test changes in a fork first
2. Document any new requirements
3. Update this README if needed
4. Follow security best practices