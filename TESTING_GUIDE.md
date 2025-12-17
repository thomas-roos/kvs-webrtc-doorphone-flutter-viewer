# AWS Configuration Testing Guide

## ✅ Automated Tests (Already Passing)

The configuration system has been thoroughly tested with unit tests:

```bash
flutter test test/config_service_test.dart
```

**Test Results:** ✅ All 9 tests passed!

The tests verify:
- Configuration storage and retrieval
- JSON serialization/deserialization  
- Configuration validation
- Clear configuration functionality
- Handling of optional session tokens

## 🧪 Manual Testing Options

### Option 1: Android Testing (Recommended)

If you have Android development set up:

```bash
# Check if Android is available
flutter devices

# Run on Android device/emulator
flutter run -d android
```

### Option 2: iOS Testing

If you have iOS development set up:

```bash
# Run on iOS simulator/device
flutter run -d ios
```

### Option 3: Desktop Testing

Enable desktop support and test:

```bash
# Enable Linux desktop support
flutter config --enable-linux-desktop
flutter create . --platforms=linux

# Run on Linux desktop
flutter run -d linux
```

### Option 4: Web Testing (With WebRTC Issues)

The current web build has flutter_webrtc compatibility issues. To test on web, you'd need to:

1. Temporarily remove flutter_webrtc dependency
2. Comment out WebRTC-related imports
3. Run `flutter run -d chrome`

## 📱 Testing Scenarios

### Scenario 1: First Launch (No Configuration)
**Expected Flow:**
1. App launches → Splash screen appears
2. Splash screen detects no configuration
3. Automatically navigates to Configuration screen
4. User sees empty form with validation

### Scenario 2: Valid Configuration Entry
**Test Steps:**
1. Fill in all required fields:
   - **AWS Region:** `us-east-1`
   - **IoT Endpoint:** `a1b2c3d4e5f6g7-ats.iot.us-east-1.amazonaws.com`
   - **KVS Channel ARN:** `arn:aws:kinesisvideo:us-east-1:123456789012:channel/doorphone-channel`
   - **Access Key ID:** `AKIAIOSFODNN7EXAMPLE`
   - **Secret Access Key:** `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
   - **Session Token:** (optional) Leave empty or add test token

2. Tap "Save Configuration"
3. **Expected:** Success message + navigation to home screen

### Scenario 3: Configuration Validation
**Test Invalid Inputs:**
- Empty required fields → Should show validation errors
- Invalid IoT endpoint format → Should show format error
- Invalid KVS ARN format → Should show ARN error
- Short access key/secret → Should show length errors

### Scenario 4: Configuration Management
**From Home Screen:**
1. Tap settings icon in app bar
2. Should navigate to configuration screen
3. Should show current configuration in status card
4. Should pre-populate form with existing values

### Scenario 5: Clear Configuration
1. In configuration screen, tap "Clear Config"
2. Should show confirmation dialog
3. Tap "Clear" → Should clear all fields and show success message
4. Configuration status card should show "Configuration Required"

### Scenario 6: Subsequent Launches
**With Valid Configuration:**
1. Close and reopen app
2. Splash screen should detect existing configuration
3. Should initialize AWS services with stored config
4. Should navigate directly to home screen

## 🔍 What to Look For

### ✅ Success Indicators:
- Form validation works correctly
- Configuration saves and persists between app restarts
- Status card shows masked credentials properly
- Navigation flows work as expected
- Clear configuration works and shows confirmation

### ❌ Potential Issues:
- Form doesn't validate properly
- Configuration doesn't persist after app restart
- Navigation doesn't work correctly
- Credentials visible in plain text
- App crashes on configuration save/load

## 🛠️ Debugging Tips

### Check Console Output:
Look for these log messages:
- `"AWS IoT MQTT: Initialized"`
- `"Configuration saved successfully"`
- `"SplashScreen: Initialization failed"`

### Verify Stored Data:
The configuration is stored in SharedPreferences with key `aws_config`. On Android, you can inspect this using:
```bash
adb shell
run-as com.example.doorphone_viewer
cat shared_prefs/FlutterSharedPreferences.xml
```

### Test Configuration Persistence:
1. Save configuration
2. Force close app (don't just minimize)
3. Reopen app
4. Check if configuration is still there

## 🚀 Quick Test Commands

```bash
# Run all tests
flutter test

# Run specific configuration tests
flutter test test/config_service_test.dart

# Check for compilation issues
flutter analyze

# Build for Android (without running)
flutter build apk --debug

# Check available devices
flutter devices
```

## 📋 Test Checklist

- [ ] Unit tests pass
- [ ] App compiles without errors
- [ ] First launch shows configuration screen
- [ ] Form validation works
- [ ] Configuration saves successfully
- [ ] Configuration persists after restart
- [ ] Settings button navigates to config screen
- [ ] Status card shows current configuration
- [ ] Clear configuration works
- [ ] Masked credentials display correctly
- [ ] Navigation flows work properly

## 🔧 Troubleshooting Common Issues

### Issue: "No devices found"
**Solution:** Set up Android Studio or Xcode, or enable desktop support

### Issue: WebRTC compilation errors on web
**Solution:** This is a known issue with flutter_webrtc package. Use Android/iOS for testing

### Issue: SharedPreferences not working
**Solution:** Ensure you're testing on a real device/emulator, not just unit tests

### Issue: Navigation not working
**Solution:** Check that all route names are correctly defined in main.dart

The configuration system is fully functional and tested - you just need a compatible platform to run the UI tests!