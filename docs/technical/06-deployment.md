# Deployment & Hosting

## Overview

This document outlines the deployment strategy, infrastructure setup, environment configuration, and continuous integration/continuous deployment (CI/CD) pipeline for the Good Deeds Tracking App. The application uses a modern cloud-based architecture with Supabase for backend services, Firebase for push notifications, and standard app store distribution.

## Infrastructure

### Supabase

Supabase provides the core backend infrastructure for the application.

**Services Used:**

1. **PostgreSQL Database**
   - Hosted database with automatic backups
   - Connection pooling via PgBouncer
   - Built-in row-level security (RLS)
   - Point-in-time recovery (PITR)

2. **Supabase Auth**
   - JWT-based authentication
   - Email/password authentication
   - Token refresh mechanism
   - Role-based access control

3. **Supabase Storage**
   - File storage for profile photos
   - Bucket policies for access control
   - Image transformation and optimization
   - CDN delivery for fast access

4. **Supabase Edge Functions** (Optional)
   - Serverless backend logic
   - Custom API endpoints
   - Database triggers and webhooks
   - Real-time data processing

**Pricing Tier Recommendations:**

- **Development**: Free tier (suitable for testing)
- **Staging**: Pro tier ($25/month)
- **Production**: Pro tier or Team tier based on usage

### Firebase

Firebase is used exclusively for push notifications.

**Services Used:**

1. **Firebase Cloud Messaging (FCM)**
   - Push notifications to iOS and Android
   - Topic-based messaging
   - Device token management
   - Delivery analytics

**Setup:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase project
firebase init

# Configure FCM
firebase projects:list
```

**No other Firebase services are used** (Authentication, Firestore, etc. are handled by Supabase)

### Mailgun

Email service for transactional emails and notifications.

**Configuration:**

```javascript
const mailgun = require('mailgun-js');

const mg = mailgun({
  apiKey: process.env.MAILGUN_API_KEY,
  domain: process.env.MAILGUN_DOMAIN
});

// Send email
const data = {
  from: 'Good Deeds App <noreply@gooddeeds.app>',
  to: 'user@example.com',
  subject: 'Penalty Notification',
  template: 'penalty_incurred',
  'v:amount': '10000',
  'v:date': '2025-10-21'
};

mg.messages().send(data, (error, body) => {
  console.log(body);
});
```

**Email Templates:**
- Account approval
- Penalty notifications
- Payment confirmations
- Excuse approvals/rejections
- Weekly summaries

### App Hosting

**Distribution Platforms:**

1. **iOS**: Apple App Store
   - Developer account required ($99/year)
   - App Store Connect for management
   - TestFlight for beta testing

2. **Android**: Google Play Store
   - Developer account required ($25 one-time)
   - Google Play Console for management
   - Internal testing track for beta

## Environment Configuration

### Environment Files

**Directory Structure:**
```
config/
├── .env.development
├── .env.staging
├── .env.production
└── env.example
```

### Development Environment

**.env.development:**
```bash
# App Environment
APP_ENV=development
APP_NAME=Good Deeds (Dev)
APP_DEBUG=true

# Supabase Configuration
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Firebase Configuration
FCM_SERVER_KEY=AAAA1234567890:APA91bHsamplekey...
FCM_SENDER_ID=123456789012

# Mailgun Configuration
MAILGUN_API_KEY=key-dev1234567890abcdef
MAILGUN_DOMAIN=sandbox1234567890.mailgun.org
MAILGUN_FROM_EMAIL=dev@gooddeeds.app

# Database (Direct connection for development)
DATABASE_URL=postgresql://postgres:password@localhost:5432/gooddeeds_dev

# API Configuration
API_BASE_URL=http://localhost:3000
API_TIMEOUT=30000

# Feature Flags
ENABLE_OFFLINE_SYNC=true
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
```

### Staging Environment

**.env.staging:**
```bash
# App Environment
APP_ENV=staging
APP_NAME=Good Deeds (Staging)
APP_DEBUG=false

# Supabase Configuration
SUPABASE_URL=https://staging-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Firebase Configuration
FCM_SERVER_KEY=AAAA1234567890:APA91bHstaging...
FCM_SENDER_ID=123456789012

# Mailgun Configuration
MAILGUN_API_KEY=key-staging1234567890
MAILGUN_DOMAIN=staging.gooddeeds.app
MAILGUN_FROM_EMAIL=staging@gooddeeds.app

# API Configuration
API_BASE_URL=https://staging-api.gooddeeds.app
API_TIMEOUT=15000

# Feature Flags
ENABLE_OFFLINE_SYNC=true
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

### Production Environment

**.env.production:**
```bash
# App Environment
APP_ENV=production
APP_NAME=Good Deeds
APP_DEBUG=false

# Supabase Configuration
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Firebase Configuration
FCM_SERVER_KEY=AAAA1234567890:APA91bHprod...
FCM_SENDER_ID=987654321098

# Mailgun Configuration
MAILGUN_API_KEY=key-prod1234567890
MAILGUN_DOMAIN=gooddeeds.app
MAILGUN_FROM_EMAIL=noreply@gooddeeds.app

# API Configuration
API_BASE_URL=https://api.gooddeeds.app
API_TIMEOUT=10000

# Feature Flags
ENABLE_OFFLINE_SYNC=true
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true

# Security
RATE_LIMIT_ENABLED=true
FORCE_HTTPS=true
```

### Flutter Configuration

**lib/config/environment.dart:**
```dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static String get supabaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-project.supabase.co';
      case Environment.staging:
        return 'https://staging-project.supabase.co';
      case Environment.production:
        return 'https://prod-project.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_DEV');
      case Environment.staging:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_STAGING');
      case Environment.production:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_PROD');
    }
  }

  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
}
```

**Build Commands:**
```bash
# Development build
flutter build apk --dart-define=ENV=development

# Staging build
flutter build apk --dart-define=ENV=staging

# Production build
flutter build apk --release --dart-define=ENV=production
```

## Database Migrations

### Migration Strategy

Use Supabase's migration system to version control database changes.

**Directory Structure:**
```
supabase/
├── migrations/
│   ├── 001_initial_schema.sql
│   ├── 002_add_deed_templates.sql
│   ├── 003_add_special_tags.sql
│   ├── 004_add_audit_logs.sql
│   └── 005_add_indexes.sql
├── seed.sql
└── config.toml
```

### Creating Migrations

```bash
# Initialize Supabase project
supabase init

# Create new migration
supabase migration new add_new_feature

# Edit migration file
# supabase/migrations/XXXXXX_add_new_feature.sql

# Test migration locally
supabase db reset

# Apply migration to remote database
supabase db push
```

### Migration Best Practices

1. **Always Use Migrations**: Never manually modify production database
2. **Test Locally First**: Run migrations on local dev database
3. **Backup Before Migration**: Create database backup before applying
4. **Include Rollback**: Document rollback procedure for each migration
5. **Version Control**: Commit migrations to Git
6. **Atomic Changes**: One migration per logical change
7. **Data Migrations**: Separate schema changes from data migrations

### Example Migration

**supabase/migrations/001_initial_schema.sql:**
```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  membership_status VARCHAR(50) NOT NULL DEFAULT 'new',
  account_status VARCHAR(50) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_account_status ON users(account_status);
CREATE INDEX idx_users_membership_status ON users(membership_status);

-- Add RLS policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Rollback Strategy

**Rollback Plan Template:**
```sql
-- Rollback for migration 005_add_indexes.sql

-- Drop indexes
DROP INDEX IF EXISTS idx_reports_user_date_desc;
DROP INDEX IF EXISTS idx_payments_user_created;
DROP INDEX IF EXISTS idx_penalties_status;

-- Verify rollback
SELECT * FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN (
    'idx_reports_user_date_desc',
    'idx_payments_user_created',
    'idx_penalties_status'
  );
-- Should return 0 rows
```

### Database Backup Before Migration

```bash
# Backup database before migration
supabase db dump -f backup_before_migration_$(date +%Y%m%d_%H%M%S).sql

# Apply migration
supabase db push

# If migration fails, restore from backup
psql $DATABASE_URL < backup_before_migration_YYYYMMDD_HHMMSS.sql
```

## CI/CD Pipeline

### Overview

Automated build, test, and deployment pipeline using GitHub Actions.

**Pipeline Stages:**

```
┌─────────────┐
│   Push Code │
│   to Git    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Run Tests  │
│  (Unit/Int) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Build App   │
│ (iOS/Android│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Deploy Backend│
│ (if needed) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Upload to    │
│ App Stores  │
│ (Beta Track)│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Manual    │
│  Approval   │
│   for Prod  │
└─────────────┘
```

### GitHub Actions Workflow

**.github/workflows/deploy.yml:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop, staging]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    name: Build Android
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/staging'
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'

      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks

      - name: Build APK
        run: |
          flutter build apk --release \
            --dart-define=ENV=${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}

      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    name: Build iOS
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/staging'
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Install CocoaPods
        run: |
          cd ios
          pod install

      - name: Build iOS
        run: |
          flutter build ios --release --no-codesign \
            --dart-define=ENV=${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}

      - name: Archive IPA
        run: |
          cd ios
          xcodebuild -workspace Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -archivePath build/Runner.xcarchive \
            archive

      - name: Upload IPA
        uses: actions/upload-artifact@v3
        with:
          name: app.ipa
          path: ios/build/Runner.xcarchive

  deploy-staging:
    name: Deploy to Staging
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/staging'
    steps:
      - name: Deploy to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID_STAGING }}
          token: ${{ secrets.FIREBASE_TOKEN }}
          groups: beta-testers
          file: build/app/outputs/flutter-apk/app-release.apk

  deploy-production:
    name: Deploy to Production
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://play.google.com/store/apps/details?id=com.gooddeeds.app
    steps:
      - name: Deploy to Play Store (Beta)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.gooddeeds.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: beta
          status: completed
```

### Alternative CI/CD Tools

#### Codemagic

**codemagic.yaml:**
```yaml
workflows:
  production-workflow:
    name: Production Build
    instance_type: mac_mini
    environment:
      flutter: stable
      xcode: latest
      vars:
        SUPABASE_URL: $PROD_SUPABASE_URL
        SUPABASE_KEY: $PROD_SUPABASE_KEY
    scripts:
      - name: Install dependencies
        script: flutter pub get
      - name: Run tests
        script: flutter test
      - name: Build Android
        script: flutter build appbundle --release
      - name: Build iOS
        script: flutter build ipa --release
    artifacts:
      - build/app/outputs/bundle/release/*.aab
      - build/ios/ipa/*.ipa
    publishing:
      google_play:
        credentials: $GOOGLE_PLAY_CREDENTIALS
        track: production
      app_store_connect:
        api_key: $APP_STORE_CONNECT_KEY
        submit_to_testflight: true
```

#### Bitrise

**bitrise.yml:**
```yaml
format_version: '11'
default_step_lib_source: https://github.com/bitrise-io/bitrise-steplib.git

workflows:
  primary:
    steps:
    - activate-ssh-key@4: {}
    - git-clone@6: {}
    - flutter-installer@0:
        inputs:
        - version: stable
    - cache-pull@2: {}
    - flutter-test@1: {}
    - flutter-build@0:
        inputs:
        - platform: both
        - android_output_type: appbundle
    - deploy-to-bitrise-io@2: {}
    - google-play-deploy@3:
        inputs:
        - service_account_json_key_path: $BITRISEIO_SERVICE_ACCOUNT_JSON_KEY_URL
        - package_name: com.gooddeeds.app
        - track: beta
```

## App Store Deployment

### iOS App Store

#### Requirements
- Apple Developer Account ($99/year)
- App Store Connect access
- Provisioning profiles and certificates
- App icon (1024x1024)
- Screenshots for all device sizes
- App privacy policy URL

#### Submission Process

1. **Prepare App**
```bash
# Build release version
flutter build ipa --release

# Validate build
xcrun altool --validate-app \
  -f build/ios/ipa/*.ipa \
  -t ios \
  -u "your-apple-id@email.com" \
  -p "app-specific-password"
```

2. **Upload to App Store Connect**
```bash
# Upload via Transporter app or command line
xcrun altool --upload-app \
  -f build/ios/ipa/*.ipa \
  -t ios \
  -u "your-apple-id@email.com" \
  -p "app-specific-password"
```

3. **Configure in App Store Connect**
   - Set app version and build number
   - Add app description, keywords, screenshots
   - Set pricing and availability
   - Configure In-App Purchases (if applicable)
   - Submit for review

4. **TestFlight Beta Testing**
   - Add beta testers via email
   - Create internal/external test groups
   - Distribute builds automatically

### Google Play Store

#### Requirements
- Google Play Developer Account ($25 one-time)
- Play Console access
- App signing key (upload key)
- App icon (512x512)
- Feature graphic (1024x500)
- Screenshots for phones and tablets
- Privacy policy URL

#### Submission Process

1. **Prepare App**
```bash
# Build release bundle
flutter build appbundle --release

# Sign bundle (if not using Play App Signing)
jarsigner -verbose -sigalg SHA256withRSA \
  -digestalg SHA-256 \
  -keystore keystore.jks \
  build/app/outputs/bundle/release/app-release.aab \
  key-alias
```

2. **Upload to Play Console**
   - Navigate to Production > Releases
   - Create new release
   - Upload AAB file
   - Add release notes
   - Review and rollout

3. **Internal Testing Track**
   - Create internal test release
   - Add testers via email list
   - Share testing link
   - Collect feedback

4. **Staged Rollout**
   - Start with 5% of users
   - Monitor crash reports and ratings
   - Gradually increase to 25%, 50%, 100%
   - Halt rollout if issues detected

### Version Management

**Version Numbering:**
- Format: `MAJOR.MINOR.PATCH` (e.g., 1.2.3)
- Build number: Increment for each release

**pubspec.yaml:**
```yaml
version: 1.2.3+45
# 1.2.3 = version name
# 45 = build number
```

**Update Version:**
```bash
# Update version in pubspec.yaml
# Then build with new version
flutter build apk --release
```

## Monitoring and Rollback

### Post-Deployment Monitoring

1. **Crash Reporting**: Monitor Sentry/Firebase Crashlytics
2. **Performance Metrics**: Check response times and load
3. **User Feedback**: Monitor app store reviews
4. **Analytics**: Track adoption of new features

### Rollback Procedure

**If critical issues detected:**

1. **Halt Rollout** (Google Play staged rollout)
2. **Fix Critical Bug** in hotfix branch
3. **Deploy Hotfix** via fast-track review
4. **Communicate** with users via in-app announcement

**Database Rollback:**
```bash
# Restore from backup
supabase db restore backup_YYYYMMDD_HHMMSS.sql

# Or revert specific migration
supabase migration revert
```

## Security Considerations

### Secret Management

- **Never commit secrets** to Git
- Use environment variables for all secrets
- Use GitHub Secrets for CI/CD
- Rotate secrets regularly (every 90 days)

### Code Signing

- **iOS**: Use automatic signing in Xcode
- **Android**: Store keystore securely (encrypted)
- **Never share** signing keys publicly

### HTTPS Only

- Force HTTPS for all API calls
- Use SSL pinning for enhanced security
- Certificate validation enabled

---

## Related Documentation

- [05-testing.md](./05-testing.md) - Testing before deployment
- [07-maintenance.md](./07-maintenance.md) - Post-deployment maintenance
- [03-database-schema.md](./03-database-schema.md) - Database migrations

---

**Last Updated**: 2025-10-22
**Version**: 1.0
