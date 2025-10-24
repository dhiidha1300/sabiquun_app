# Sabiquun App - Setup Guide

This guide will help you set up and run the Sabiquun app locally.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (latest stable version)
- **Dart** 3.0+
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**

## Step 1: Clone the Repository

```bash
git clone https://github.com/dhiidha1300/sabiquun_app.git
cd sabiquun_app/sabiquun_app
```

## Step 2: Install Dependencies

```bash
flutter pub get
```

## Step 3: Generate Code

The app uses code generation for models. Run the following command:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 4: Configure Environment

### Create .env File

Copy the example environment file and configure it:

```bash
cp ../.env.example .env
```

### Update .env with Your Credentials

Open `.env` and add your Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
APP_ENV=development
FCM_SERVER_KEY=your-fcm-server-key
MAILGUN_API_KEY=your-mailgun-api-key
MAILGUN_DOMAIN=your-mailgun-domain
```

**Where to find these values:**

1. **Supabase URL & Anon Key:**
   - Go to your [Supabase Dashboard](https://app.supabase.com/)
   - Select your project
   - Go to Settings > API
   - Copy the `Project URL` and `anon public` key

2. **FCM Server Key:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings > Cloud Messaging
   - Copy the Server Key

3. **Mailgun:** (Optional - Admin can configure later)
   - Go to [Mailgun Dashboard](https://app.mailgun.com/)
   - Get your API key and domain

## Step 5: Database Setup

Make sure you have created all 24 tables in your Supabase database. Refer to the documentation:

- [Database Schema](../docs/database/01-schema.md)

### Enable Row Level Security (RLS)

Ensure RLS policies are set up correctly in Supabase for secure access control.

## Step 6: Run the App

### For Android/iOS Emulator

```bash
# Start an emulator first (Android Studio or Xcode)
flutter run
```

### For Specific Platform

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

### For Release Build

```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Project Structure

```
lib/
├── core/
│   ├── config/         # Environment configuration
│   ├── constants/      # App-wide constants
│   ├── di/             # Dependency injection
│   ├── errors/         # Error handling
│   ├── navigation/     # App routing
│   ├── theme/          # App theme and colors
│   └── utils/          # Utility functions
├── features/
│   ├── auth/           # Authentication feature
│   │   ├── data/       # Models, repositories, data sources
│   │   ├── domain/     # Entities, repository interfaces
│   │   └── presentation/ # Screens, widgets, BLoC
│   └── home/           # Home feature
└── shared/
    ├── services/       # Shared services
    └── widgets/        # Reusable widgets
```

## Authentication Flow

1. **Login** → Checks credentials with Supabase
2. **Sign Up** → Creates user with `pending` status
3. **Admin Approval** → Admin must approve new users
4. **Access Granted** → User can login after approval

## User Roles

- **User**: Basic access for deed tracking
- **Supervisor**: Can view all reports and approve excuses
- **Cashier**: Can manage payments and penalties
- **Admin**: Full system access

## Troubleshooting

### Issue: Environment not configured

**Error:** `Exception: Environment not configured properly`

**Solution:** Make sure your `.env` file exists and contains valid Supabase credentials.

### Issue: Build runner fails

**Error:** Conflicts in generated files

**Solution:** Run with delete conflicts flag:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Supabase connection failed

**Solution:**
- Check your internet connection
- Verify Supabase URL and anon key are correct
- Ensure Supabase project is active

### Issue: Login fails even with correct credentials

**Solution:**
- Check account status (must be `active`)
- New users need admin approval
- Check Supabase auth logs

## Development Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Clean build
flutter clean
flutter pub get

# Check for outdated packages
flutter pub outdated
```

## Next Steps

1. Configure your Supabase project with the required tables
2. Set up Row Level Security policies
3. Create the first admin user manually in Supabase
4. Test the complete authentication flow
5. Start implementing other features (deeds, payments, etc.)

## Support

For issues or questions:
- Check the [main documentation](../README.md)
- Review the [technical documentation](../docs/technical/)
- Contact: support@sabiquun.app

---

**Last Updated:** 2025-10-24
