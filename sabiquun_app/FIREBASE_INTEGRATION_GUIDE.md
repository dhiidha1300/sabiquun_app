# Firebase Integration Guide

## Overview

Firebase Crashlytics and Analytics have been successfully integrated into the Sabiquun app. This guide explains how to use these services throughout the application.

## What's Configured

### ✅ Firebase Crashlytics
- **Purpose**: Automatically track crashes and errors in production
- **Status**: Fully configured and active in release builds
- **Disabled in**: Debug mode (to avoid development noise)

### ✅ Firebase Analytics
- **Purpose**: Track user behavior, events, and app usage
- **Status**: Fully configured and ready to use
- **Privacy**: Compliant with user privacy settings

## How to Use Firebase Service

### Accessing the Firebase Service

The Firebase service is available globally through dependency injection:

```dart
import 'package:sabiquun_app/core/di/injection.dart';

// Access the service
final firebaseService = Injection.firebaseService;
```

### Logging Errors to Crashlytics

#### Example 1: In BLoC Error Handlers

```dart
import 'package:sabiquun_app/core/di/injection.dart';

Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    // Your login logic here
    final user = await authRepository.login(event.email, event.password);
    emit(Authenticated(user));
  } catch (e, stackTrace) {
    // Log the error to Crashlytics
    await Injection.firebaseService.recordError(
      e,
      stackTrace,
      reason: 'Login failed for user: ${event.email}',
      fatal: false,
    );

    emit(AuthError(e.toString()));
  }
}
```

#### Example 2: In Repository Methods

```dart
@override
Future<Either<Failure, List<Deed>>> getUserDeeds(String userId) async {
  try {
    final deeds = await remoteDataSource.getUserDeeds(userId);
    return Right(deeds);
  } catch (e, stackTrace) {
    // Log error to Crashlytics
    await Injection.firebaseService.recordError(
      e,
      stackTrace,
      reason: 'Failed to fetch deeds for user: $userId',
    );

    return Left(ServerFailure('Failed to load deeds'));
  }
}
```

#### Example 3: Setting User Context

When a user logs in, set their ID in Crashlytics for better debugging:

```dart
// In AuthBloc after successful login
await Injection.firebaseService.setUserIdentifier(user.id);

// You can also set custom keys
await Injection.firebaseService.setCustomKey('user_role', user.role);
await Injection.firebaseService.setCustomKey('membership_status', user.membershipStatus);
```

### Logging Analytics Events

#### Built-in Analytics Events

```dart
// Log user login
await Injection.firebaseService.logLogin(method: 'email');

// Log screen view
await Injection.firebaseService.logScreenView(
  screenName: 'home_page',
  screenClass: 'HomePage',
);

// Set user properties
await Injection.firebaseService.setUserId(user.id);
await Injection.firebaseService.setUserProperty(
  name: 'user_role',
  value: user.role,
);
```

#### Custom Analytics Events (Already Implemented)

```dart
// Log deed submission
await Injection.firebaseService.logDeedSubmission(
  deedTotal: 8.5,
  membershipStatus: 'active',
);

// Log payment submission
await Injection.firebaseService.logPaymentSubmission(
  amount: 50000.0,
  paymentMethod: 'bank_transfer',
);

// Log excuse request
await Injection.firebaseService.logExcuseRequest(
  excuseType: 'sick',
);

// Log penalty incurred
await Injection.firebaseService.logPenaltyIncurred(
  penaltyAmount: 10000.0,
  reason: 'missed_fajr',
);

// Log offline sync
await Injection.firebaseService.logOfflineSync(
  itemsSynced: 5,
  success: true,
);
```

#### Custom Event (Generic)

```dart
await Injection.firebaseService.logEvent(
  name: 'feature_used',
  parameters: {
    'feature_name': 'export_report',
    'export_format': 'pdf',
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

## Where to Add Analytics Events

### Recommended Event Locations

1. **Authentication Events**
   - Location: `lib/features/auth/presentation/bloc/auth_bloc.dart`
   - Events: `logLogin()`, `logSignUp()`, `setUserId()`

2. **Deed Submission**
   - Location: `lib/features/deeds/presentation/bloc/deed_bloc.dart`
   - Events: `logDeedSubmission()`

3. **Payment Events**
   - Location: `lib/features/payments/presentation/bloc/payment_bloc.dart`
   - Events: `logPaymentSubmission()`

4. **Excuse Requests**
   - Location: `lib/features/excuses/presentation/bloc/excuse_bloc.dart`
   - Events: `logExcuseRequest()`

5. **Screen Views**
   - Location: Each page's `initState()` or `build()` method
   - Events: `logScreenView()`

6. **Feature Usage**
   - Location: Wherever a major feature is used
   - Events: Custom `logEvent()`

## Example: Complete Integration in a BLoC

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/core/di/injection.dart';
import 'package:sabiquun_app/features/deeds/domain/repositories/deed_repository.dart';

class DeedBloc extends Bloc<DeedEvent, DeedState> {
  final DeedRepository repository;

  DeedBloc(this.repository) : super(DeedInitial()) {
    on<SubmitDeedEvent>(_onSubmitDeed);
  }

  Future<void> _onSubmitDeed(
    SubmitDeedEvent event,
    Emitter<DeedState> emit,
  ) async {
    emit(DeedLoading());

    try {
      // Submit the deed
      final deed = await repository.submitDeed(event.deed);

      // Log successful submission to Analytics
      await Injection.firebaseService.logDeedSubmission(
        deedTotal: event.deed.total,
        membershipStatus: event.deed.userMembershipStatus,
      );

      // Log custom event with more details
      await Injection.firebaseService.logEvent(
        name: 'deed_submitted',
        parameters: {
          'faraidTotal': event.deed.faraidTotal,
          'sunnahTotal': event.deed.sunnahTotal,
          'submission_method': 'manual',
        },
      );

      emit(DeedSubmitted(deed));
    } catch (e, stackTrace) {
      // Log error to Crashlytics
      await Injection.firebaseService.recordError(
        e,
        stackTrace,
        reason: 'Failed to submit deed',
        fatal: false,
      );

      // Log failed attempt to Analytics
      await Injection.firebaseService.logEvent(
        name: 'deed_submission_failed',
        parameters: {
          'error_type': e.runtimeType.toString(),
        },
      );

      emit(DeedError(e.toString()));
    }
  }
}
```

## Testing Crashlytics

### Test in Debug Mode

Although Crashlytics is disabled in debug mode, you can test it by forcing collection:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Enable in debug mode temporarily
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

// Force a test crash
Injection.firebaseService.forceCrash();
```

### Test in Release Mode

1. Build a release APK: `flutter build apk --release`
2. Install on a device
3. Trigger an error or crash
4. Wait 5-10 minutes
5. Check Firebase Console → Crashlytics

## Viewing Analytics and Crash Reports

### Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **sabiquun-65e5b**
3. Navigate to:
   - **Crashlytics**: View crashes and errors
   - **Analytics**: View events and user behavior

### Crashlytics Dashboard

- **Crashes**: Fatal errors that caused the app to crash
- **Non-fatals**: Caught errors that were logged
- **Users affected**: Number of users impacted
- **Stack traces**: Detailed error information

### Analytics Dashboard

- **Events**: All logged events
- **User Properties**: Custom user attributes
- **Audiences**: User segments
- **Funnels**: User journey analysis

## Best Practices

### ✅ DO

- Log all caught exceptions to Crashlytics
- Set user ID and properties after login
- Log important user actions as Analytics events
- Use descriptive event names (snake_case)
- Add context with custom keys before errors
- Test crashes in staging before production

### ❌ DON'T

- Log sensitive information (passwords, tokens)
- Log PII without user consent
- Over-log trivial events (every button click)
- Use Crashlytics for non-error logging
- Enable Crashlytics in debug mode (already disabled)

## Privacy Compliance

### User Data Collection

The app collects:
- Crash reports (anonymous stack traces)
- Analytics events (user actions)
- User IDs (for debugging)
- Device information (OS, model)

### GDPR/Privacy

- Inform users in Privacy Policy
- Allow users to opt-out if required
- Don't log personal data in events
- Use anonymized user IDs when possible

## Troubleshooting

### Crashlytics Not Working

1. Check Firebase Console → Crashlytics is enabled
2. Verify google-services.json is in `android/app/`
3. Ensure app is running in release mode
4. Wait 5-10 minutes for reports to appear
5. Check Gradle build includes Crashlytics plugin

### Analytics Not Appearing

1. Verify Firebase Analytics is enabled
2. Check events in DebugView (Firebase Console)
3. Wait up to 24 hours for events to process
4. Ensure event names follow Firebase naming rules

### Build Errors

1. Run `flutter clean && flutter pub get`
2. Check Gradle files for correct plugin versions
3. Verify Java version (JDK 11 required)
4. Check ProGuard rules if obfuscation is enabled

## Additional Resources

- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)
- [Firebase Analytics Docs](https://firebase.google.com/docs/analytics)
- [Flutter Firebase Docs](https://firebase.flutter.dev/)

---

**Last Updated**: 2025-11-25
**Version**: 1.0.0
