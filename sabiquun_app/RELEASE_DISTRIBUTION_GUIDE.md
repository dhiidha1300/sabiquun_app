# Release & Distribution Guide

## Quick Start - Building the Release APK

### Prerequisites Checklist
- ✅ Firebase configured (google-services.json in place)
- ✅ Release keystore generated
- ✅ key.properties file created
- ✅ Application ID updated to `com.negeeyedev.sabiquun`
- ✅ .env file configured

### Build Commands

#### Clean Build (Recommended)
```bash
cd a:\sabiquun_app\sabiquun_app
flutter clean
flutter pub get
flutter build apk --release
```

#### Build with Split ABIs (Smaller file sizes)
```bash
flutter build apk --release --split-per-abi
```

This creates separate APKs for different CPU architectures:
- `app-armeabi-v7a-release.apk` (~25MB) - 32-bit ARM devices
- `app-arm64-v8a-release.apk` (~28MB) - 64-bit ARM devices (most modern phones)
- `app-x86_64-release.apk` (~30MB) - Intel/AMD devices (emulators)

**Recommendation**: Distribute `app-arm64-v8a-release.apk` for most users.

### Build Output Location

```
a:\sabiquun_app\sabiquun_app\build\app\outputs\flutter-apk\
├── app-release.apk              (Universal APK ~45MB)
├── app-armeabi-v7a-release.apk  (32-bit ARM)
├── app-arm64-v8a-release.apk    (64-bit ARM)
└── app-x86_64-release.apk       (Intel/AMD)
```

---

## Distribution Method 1: Firebase App Distribution (RECOMMENDED)

### Why Firebase App Distribution?
- ✅ Easy setup and management
- ✅ Automatic update notifications
- ✅ Integrated with Firebase Crashlytics
- ✅ Tester management via email
- ✅ No Play Store approval needed
- ✅ Perfect for beta testing

### Setup Steps

#### 1. Install Firebase CLI

```bash
# Install Node.js first if not installed
# Download from: https://nodejs.org/

# Install Firebase CLI
npm install -g firebase-tools

# Verify installation
firebase --version
```

#### 2. Login to Firebase

```bash
firebase login
```

This will open a browser window. Sign in with the Google account that has access to your Firebase project.

#### 3. Initialize Firebase App Distribution

```bash
cd a:\sabiquun_app\sabiquun_app
firebase init appdistribution
```

Select your Firebase project: **sabiquun-65e5b**

#### 4. Distribute the APK

```bash
# Build the APK first
flutter build apk --release

# Distribute to testers
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:287295827460:android:5a38ddbeff677545518f51 \
  --groups "beta-testers" \
  --release-notes "Initial beta release for testing. Please report any bugs or issues."
```

#### 5. Create Tester Groups

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select project: **sabiquun-65e5b**
3. Navigate to: **App Distribution** → **Testers & Groups**
4. Click **Add Group**
5. Name: `beta-testers`
6. Add tester emails (separated by commas or line breaks)

#### 6. Testers Install the App

Testers will receive an email invitation with:
- Link to download the app
- Instructions to install
- Release notes

**Important**: Testers must enable "Install from Unknown Sources" on Android.

### Distribute Updates

```bash
# Build new version
flutter build apk --release

# Distribute update
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:287295827460:android:5a38ddbeff677545518f51 \
  --groups "beta-testers" \
  --release-notes "Version 1.0.1 - Bug fixes and improvements"
```

---

## Distribution Method 2: Direct APK Sharing

### Pros
- Simplest method
- No additional tools required
- Works offline

### Cons
- No automatic updates
- Manual distribution
- No analytics
- Less professional

### Steps

1. **Build the APK**
```bash
flutter build apk --release
```

2. **Upload to File Sharing Service**
   - Google Drive
   - Dropbox
   - OneDrive
   - WeTransfer

3. **Share the Link**
   - Share the download link with testers
   - Include installation instructions

4. **Installation Instructions for Testers**

```
1. Download the APK file from the link
2. Open Settings → Security → Enable "Install from Unknown Sources"
3. Open the downloaded APK file
4. Tap "Install"
5. Open the app and test!
```

---

## Distribution Method 3: Google Play Internal Testing

### Why Google Play?
- ✅ Professional distribution
- ✅ Automatic updates via Play Store
- ✅ No "Unknown Sources" warning
- ✅ Crash reports in Play Console
- ✅ Up to 100 internal testers

### Prerequisites
- Google Play Developer Account ($25 one-time fee)
- Signed release APK or AAB

### Steps

#### 1. Create Play Console Account

1. Go to: https://play.google.com/console
2. Pay the $25 registration fee
3. Complete the developer profile

#### 2. Create App in Play Console

1. Click "Create App"
2. App name: **Sabiquun**
3. Default language: **English (United States)** or your language
4. App type: **App**
5. Category: **Productivity** or **Lifestyle**

#### 3. Build App Bundle (AAB)

```bash
# AAB is preferred by Google Play
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### 4. Upload to Internal Testing

1. In Play Console → **Testing** → **Internal testing**
2. Click **Create new release**
3. Upload `app-release.aab`
4. Add release notes
5. Review and roll out

#### 5. Add Internal Testers

1. **Testing** → **Internal testing** → **Testers**
2. Click **Create email list**
3. Add tester emails
4. Save and send invitations

#### 6. Testers Join via Link

Testers receive:
- Email invitation
- Opt-in link
- Install via Play Store (automatic updates!)

---

## Version Management

### Version Number Format

```yaml
# In pubspec.yaml
version: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

Example: `1.0.0+1`
- **1** = Major version (breaking changes)
- **0** = Minor version (new features)
- **0** = Patch version (bug fixes)
- **1** = Build number (increment for each build)

### Update Version

```yaml
# pubspec.yaml

# Initial release
version: 1.0.0+1

# First update (bug fixes)
version: 1.0.1+2

# Second update (new feature)
version: 1.1.0+3

# Major update (breaking changes)
version: 2.0.0+4
```

### Build Commands with Version

```bash
# Override version at build time (optional)
flutter build apk --release --build-name=1.0.1 --build-number=2
```

---

## Testing Before Distribution

### Critical Test Checklist

Before distributing to testers, verify:

#### Authentication
- [ ] Login with valid credentials works
- [ ] Login with invalid credentials fails appropriately
- [ ] Logout works
- [ ] Password reset works
- [ ] Session persists after app restart

#### Core Features
- [ ] Submit daily deed report
- [ ] View deed history
- [ ] Submit payment
- [ ] View payment history
- [ ] Request excuse
- [ ] View penalties

#### Permissions
- [ ] Internet access works
- [ ] Image picker works (for payment receipts)
- [ ] File download works (export reports)

#### Firebase Integration
- [ ] Trigger a test crash (to verify Crashlytics)
- [ ] Check Firebase Console for crash report
- [ ] Verify analytics events appear in Firebase

#### Performance
- [ ] App launches within 3 seconds
- [ ] No visible lag when navigating
- [ ] Images load smoothly
- [ ] No ANR (Application Not Responding)

### Test Crash (Firebase Crashlytics)

Add this button temporarily in Settings for testing:

```dart
ElevatedButton(
  onPressed: () {
    Injection.firebaseService.forceCrash();
  },
  child: Text('Test Crash (Debug Only)'),
)
```

**Remove before production!**

---

## Installation Instructions for Testers

### PDF/Document to Share with Testers

```markdown
# Sabiquun App - Beta Testing Installation Guide

Thank you for participating in beta testing!

## Installation Steps

### Android Devices

1. **Download the App**
   - Click the download link provided
   - Or open the Firebase App Distribution email

2. **Enable Installation from Unknown Sources**
   - Open Settings → Security
   - Enable "Install from Unknown Sources" or "Unknown Sources"
   - (On Android 8+: Settings → Apps → Special Access → Install Unknown Apps)

3. **Install the App**
   - Locate the downloaded APK file (usually in Downloads folder)
   - Tap the file to install
   - Grant any requested permissions
   - Tap "Install"

4. **Open and Test**
   - Find "Sabiquun" on your home screen or app drawer
   - Create an account or login
   - Test the features

## What to Test

Please test these core features:
- Login/Registration
- Submit daily deed report
- Make payments
- Request excuses
- View reports and history

## Reporting Issues

If you encounter any bugs or issues:
1. Take a screenshot (if possible)
2. Note the steps to reproduce
3. Email to: [YOUR_EMAIL]
4. Or report in our WhatsApp/Telegram group: [LINK]

## Privacy

This is a beta version. Your data is secure but we recommend:
- Don't use production/real payment information yet
- Test data may be reset between versions

Thank you for helping us improve Sabiquun!
```

---

## Monitoring Beta Distribution

### Firebase Console Dashboards

#### App Distribution
- **URL**: https://console.firebase.google.com/project/sabiquun-65e5b/appdistribution
- **Metrics**: Downloads, active testers, feedback

#### Crashlytics
- **URL**: https://console.firebase.google.com/project/sabiquun-65e5b/crashlytics
- **Metrics**: Crash-free users, crash count, stack traces

#### Analytics
- **URL**: https://console.firebase.google.com/project/sabiquun-65e5b/analytics
- **Metrics**: Active users, events, retention

### Key Metrics to Track

| Metric | Target | How to Improve |
|--------|--------|----------------|
| Crash-free rate | >99% | Fix crashes immediately |
| Daily Active Users | Growing | Engage testers, add features |
| Average session duration | >5 min | Improve UX, add value |
| Retention (Day 7) | >30% | Fix bugs, listen to feedback |

---

## Troubleshooting

### Build Issues

#### Problem: Keystore not found
```
Solution: Ensure key.properties is in android/ directory
```

#### Problem: Firebase plugin error
```
Solution: Run flutter clean && flutter pub get
```

#### Problem: Build takes too long
```
Solution: Disable ProGuard temporarily (only for testing!)
In build.gradle.kts: isMinifyEnabled = false
```

### Installation Issues

#### Problem: "App not installed"
```
Solution 1: Uninstall previous version
Solution 2: Check device storage
Solution 3: Rebuild with --no-shrink flag
```

#### Problem: "Unknown sources blocked"
```
Solution: Settings → Security → Enable Unknown Sources
```

---

## Next Steps After Beta Testing

1. **Collect Feedback** (1-2 weeks)
2. **Fix Critical Bugs**
3. **Implement Feedback**
4. **Prepare for Production Release**
5. **Submit to Google Play Store**

---

## Security Reminders

### DO NOT:
- ❌ Share keystore password publicly
- ❌ Commit key.properties to Git
- ❌ Distribute unsigned/debug APKs
- ❌ Ignore security vulnerabilities

### DO:
- ✅ Keep keystore backed up securely
- ✅ Use environment variables for secrets
- ✅ Test on multiple devices
- ✅ Monitor crash reports daily

---

**Last Updated**: 2025-11-25
**App Version**: 1.0.0
**Build**: 1
