# CI Testing Guide - AWS Configuration System

## 🚀 Using Existing GitHub Actions

Your project already has a comprehensive CI/CD setup! Here's how to test the new AWS configuration system:

## 📋 Current Workflows Available

### 1. **Continuous Integration** (`.github/workflows/ci.yml`)
- ✅ Runs on every push/PR
- ✅ Code analysis and formatting checks
- ✅ Runs all tests (including our new config tests)
- ✅ Builds debug APK to verify compilation

### 2. **Android Build & Release** (`.github/workflows/build-android.yml`)
- ✅ Builds both debug and release APKs
- ✅ Uploads APKs as downloadable artifacts
- ✅ Creates GitHub releases for tagged versions
- ✅ Handles certificates and Firebase config

## 🎯 How to Test the Configuration System

### Option 1: Push to Trigger CI Build
```bash
# Make sure your changes are committed
git add .
git commit -m "feat: add AWS configuration system"
git push origin main
```

**What happens:**
1. CI workflow runs automatically
2. Tests our configuration system (all 9 tests)
3. Builds debug APK with new config features
4. APK available as artifact for download

### Option 2: Manual Workflow Trigger
1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Build and Release Android APK**
4. Click **Run workflow**
5. Choose branch and click **Run workflow**

### Option 3: Create a Release Tag
```bash
# Create and push a version tag
git tag -a v1.1.0 -m "Add AWS configuration system"
git push origin v1.1.0
```

**What happens:**
1. Builds both debug and release APKs
2. Creates a GitHub release with downloadable files
3. APKs ready for installation and testing

## 📱 Download and Test APK

### After CI Build Completes:

1. **Go to Actions tab** in your GitHub repo
2. **Click on the latest workflow run**
3. **Scroll down to Artifacts section**
4. **Download** `doorphone-viewer-debug-apk` or `doorphone-viewer-release-apk`
5. **Install on Android device**:
   ```bash
   # Via ADB
   adb install doorphone-viewer-debug-*.apk
   
   # Or transfer to device and install manually
   ```

## 🧪 Testing Scenarios on Real Device

### Test 1: First Launch Flow
1. Install fresh APK
2. Launch app
3. **Expected:** Configuration screen appears automatically
4. **Test:** Fill in AWS credentials and save

### Test 2: Configuration Persistence
1. Enter configuration and save
2. Force close app
3. Reopen app
4. **Expected:** Goes directly to home screen (config persists)

### Test 3: Configuration Management
1. From home screen, tap settings icon
2. **Expected:** Shows configuration screen with current values
3. **Test:** Update values, clear config, etc.

## 🔍 Monitoring CI Results

### Check Test Results:
- All workflows run our new configuration tests
- Look for ✅ "Run Flutter tests" step
- Should show "9 tests passed"

### Check Build Success:
- Look for ✅ "Build APK (Debug)" step
- Artifact should be uploaded successfully

### Download Links:
- Debug APK: Available immediately after CI build
- Release APK: Available after tagged release

## 🛠️ Troubleshooting CI Issues

### If Tests Fail:
```bash
# Run tests locally first
flutter test test/config_service_test.dart
```

### If Build Fails:
```bash
# Check compilation locally
flutter analyze
flutter build apk --debug
```

### If Artifacts Missing:
- Check workflow logs for upload errors
- Ensure workflow completed successfully
- Artifacts expire after 30 days (debug) / 90 days (release)

## 📋 Quick Testing Checklist

- [ ] Push changes to trigger CI
- [ ] Verify tests pass in Actions tab
- [ ] Download debug APK artifact
- [ ] Install on Android device
- [ ] Test first launch → config screen
- [ ] Test configuration save/load
- [ ] Test settings navigation
- [ ] Test configuration persistence
- [ ] Test clear configuration

## 🎉 Ready to Test!

Your existing CI system is perfect for testing the new configuration features. Just push your changes and download the generated APK to test on a real device!

### Quick Commands:
```bash
# Trigger CI build
git push origin main

# Or create release
git tag v1.1.0 && git push origin v1.1.0
```

Then check the **Actions** tab for your downloadable APK! 🚀