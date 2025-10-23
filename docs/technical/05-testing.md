# Testing Strategy

## Overview

Comprehensive testing is essential for ensuring the Good Deeds Tracking App functions correctly across all features, handles edge cases gracefully, and performs well under load. This document outlines the testing strategy covering unit tests, integration tests, end-to-end tests, performance testing, and user acceptance testing.

## Testing Pyramid

```
        /\
       /  \
      / E2E \
     /--------\
    /          \
   / Integration \
  /--------------\
 /                \
/   Unit Tests     \
--------------------
```

- **Unit Tests**: 70% of test coverage (foundation)
- **Integration Tests**: 20% of test coverage (connections)
- **End-to-End Tests**: 10% of test coverage (critical flows)

## Unit Tests

Unit tests focus on testing individual functions, methods, and components in isolation.

### Backend Testing (Supabase Functions)

#### Test Coverage Areas

1. **Penalty Calculation Logic**
```javascript
describe('Penalty Calculation', () => {
  test('should calculate correct penalty for missed deeds', () => {
    const target = 10;
    const actual = 7.5;
    const missed = target - actual; // 2.5
    const penalty = calculatePenalty(missed);

    expect(penalty).toBe(12500); // 2.5 * 5000
  });

  test('should not penalize new members', () => {
    const user = { membership_status: 'new' };
    const penalty = shouldCalculatePenalty(user, '2025-10-21');

    expect(penalty).toBe(false);
  });

  test('should not penalize on rest days', () => {
    const restDay = '2025-10-15';
    const penalty = shouldCalculatePenalty(user, restDay);

    expect(penalty).toBe(false);
  });

  test('should handle fractional deed penalties', () => {
    const missed = 0.3; // 3 Sunnah prayers
    const penalty = calculatePenalty(missed);

    expect(penalty).toBe(1500); // 0.3 * 5000
  });
});
```

2. **Payment FIFO Application**
```javascript
describe('Payment FIFO Application', () => {
  test('should apply payment to oldest penalty first', async () => {
    const penalties = [
      { id: 1, amount: 10000, date: '2025-10-01' },
      { id: 2, amount: 15000, date: '2025-10-05' },
      { id: 3, amount: 20000, date: '2025-10-10' }
    ];
    const payment = 25000;

    const result = await applyPaymentFIFO(payment, penalties);

    expect(result.paid).toEqual([
      { id: 1, amount: 10000, status: 'paid' },
      { id: 2, amount: 15000, status: 'paid' }
    ]);
    expect(result.remaining).toBe(0);
  });

  test('should partially pay oldest penalty if payment insufficient', async () => {
    const penalties = [
      { id: 1, amount: 10000, date: '2025-10-01' },
      { id: 2, amount: 15000, date: '2025-10-05' }
    ];
    const payment = 5000;

    const result = await applyPaymentFIFO(payment, penalties);

    expect(result.paid).toEqual([
      { id: 1, amount: 5000, status: 'partial' }
    ]);
    expect(penalties[0].remaining).toBe(5000);
  });
});
```

3. **Deed Total Calculation**
```javascript
describe('Deed Total Calculation', () => {
  test('should sum binary and fractional deeds correctly', () => {
    const deedValues = {
      fajr: 1,
      duha: 1,
      dhuhr: 1,
      juz: 1,
      asr: 1,
      sunnah_prayers: 0.6,
      maghrib: 1,
      isha: 1,
      athkar: 0,
      witr: 1
    };

    const total = calculateDeedTotal(deedValues);
    expect(total).toBe(8.6);
  });
});
```

4. **Membership Status Calculation**
```javascript
describe('Membership Status Calculation', () => {
  test('should set new member status for accounts < 30 days', () => {
    const createdAt = moment().subtract(20, 'days');
    const status = calculateMembershipStatus(createdAt);

    expect(status).toBe('new');
  });

  test('should set exclusive member status for 1 month - 3 years', () => {
    const createdAt = moment().subtract(1, 'year');
    const status = calculateMembershipStatus(createdAt);

    expect(status).toBe('exclusive');
  });

  test('should set legacy member status for 3+ years', () => {
    const createdAt = moment().subtract(4, 'years');
    const status = calculateMembershipStatus(createdAt);

    expect(status).toBe('legacy');
  });
});
```

5. **Statistics Recalculation**
```javascript
describe('User Statistics Recalculation', () => {
  test('should recalculate total reports submitted', async () => {
    const userId = 'user-123';
    await recalculateUserStatistics(userId);

    const stats = await getUserStatistics(userId);
    expect(stats.total_reports_submitted).toBe(45);
  });

  test('should recalculate current streak correctly', async () => {
    const userId = 'user-123';
    await recalculateUserStatistics(userId);

    const stats = await getUserStatistics(userId);
    expect(stats.current_streak_days).toBe(7);
  });
});
```

**Backend Testing Tools:**
- **Jest**: JavaScript testing framework
- **Supabase Local Development**: Test against local database
- **pg-mock**: Mock PostgreSQL queries
- **Coverage Target**: 80%+ for backend logic

### Frontend Testing (Flutter)

#### Test Coverage Areas

1. **Widget Rendering**
```dart
testWidgets('Report Form renders correctly', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: ReportForm()));

  expect(find.text('Daily Deed Report'), findsOneWidget);
  expect(find.byType(DeedInputField), findsNWidgets(10));
  expect(find.text('Submit Report'), findsOneWidget);
});
```

2. **Form Validation**
```dart
testWidgets('Form validates deed values', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: ReportForm()));

  // Enter invalid fractional value
  await tester.enterText(
    find.byKey(Key('sunnah_prayers_input')),
    '1.5' // Invalid: exceeds max 1.0
  );

  await tester.tap(find.text('Submit Report'));
  await tester.pump();

  expect(find.text('Value must be between 0 and 1'), findsOneWidget);
});
```

3. **Navigation Flows**
```dart
testWidgets('Navigation from home to report form works',
    (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: HomePage()));

  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  expect(find.byType(ReportForm), findsOneWidget);
});
```

4. **State Management**
```dart
test('ReportBloc handles submit event correctly', () async {
  final bloc = ReportBloc();
  final report = Report(/* ... */);

  bloc.add(SubmitReportEvent(report));

  await expectLater(
    bloc.stream,
    emitsInOrder([
      ReportSubmitting(),
      ReportSubmitSuccess(),
    ]),
  );
});
```

**Frontend Testing Tools:**
- **Flutter Test**: Built-in testing framework
- **Mockito**: Mocking dependencies
- **Bloc Test**: Testing BLoC state management
- **Golden Tests**: Visual regression testing
- **Coverage Target**: 70%+ for frontend code

## Integration Tests

Integration tests verify that different parts of the system work correctly together.

### API Testing

Test all endpoints with various payloads to ensure proper request/response handling.

**Example Test Suite (Postman/Newman):**

```javascript
// Test: Create Report API
pm.test("POST /api/reports - Create draft report", function() {
  const response = pm.response.json();

  pm.expect(response.status).to.equal('draft');
  pm.expect(response.user_id).to.equal(pm.environment.get('user_id'));
  pm.expect(response.deed_total).to.be.within(0, 10);
});

// Test: Authentication
pm.test("401 Unauthorized without token", function() {
  pm.response.to.have.status(401);
});

// Test: Authorization
pm.test("403 Forbidden for insufficient permissions", function() {
  pm.response.to.have.status(403);
});
```

**API Test Coverage:**

1. **Authentication & Authorization**
   - Valid login credentials
   - Invalid credentials
   - Expired tokens
   - Role-based access control
   - Missing authorization headers

2. **Rate Limiting**
   - Test exceeding rate limits
   - Verify rate limit headers
   - Test rate limit reset

3. **Error Responses**
   - Invalid request payloads
   - Missing required fields
   - Malformed JSON
   - Database constraint violations

4. **Edge Cases**
   - Concurrent requests
   - Large payloads
   - Special characters in input
   - Boundary values

**Tools:**
- **Postman**: API testing and documentation
- **Newman**: Automated Postman collection runner
- **Supertest**: HTTP assertion library for Node.js

### Database Testing

Test database triggers, constraints, and performance.

**Test Cases:**

1. **Database Triggers**
```sql
-- Test: updated_at trigger
INSERT INTO reports (user_id, date, deed_total, status)
VALUES ('user-123', '2025-10-21', 8.5, 'submitted');

SELECT updated_at FROM reports WHERE user_id = 'user-123'
  AND date = '2025-10-21';
-- Expect: updated_at is set to current timestamp
```

2. **Foreign Key Constraints**
```sql
-- Test: Cannot create report for non-existent user
INSERT INTO reports (user_id, date, deed_total, status)
VALUES ('invalid-user', '2025-10-21', 8.5, 'submitted');
-- Expect: Foreign key constraint violation
```

3. **Unique Constraints**
```sql
-- Test: Cannot submit duplicate report for same date
INSERT INTO reports (user_id, date, deed_total, status)
VALUES ('user-123', '2025-10-21', 8.5, 'submitted');

INSERT INTO reports (user_id, date, deed_total, status)
VALUES ('user-123', '2025-10-21', 9.0, 'submitted');
-- Expect: Unique constraint violation
```

4. **Index Performance**
```sql
-- Test: Query uses proper index
EXPLAIN ANALYZE
SELECT * FROM reports
WHERE user_id = 'user-123'
  AND date >= '2025-10-01'
  AND date <= '2025-10-31';
-- Verify: Uses idx_reports_user_date index
```

**Tools:**
- **pgTAP**: PostgreSQL testing framework
- **Database Migration Tests**: Test each migration
- **Supabase Studio**: Manual database testing

## End-to-End Tests

E2E tests simulate complete user journeys from start to finish.

### Critical User Flows

#### 1. User Registration & Approval

```dart
testWidgets('Complete registration flow', (WidgetTester tester) async {
  // User signs up
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Sign Up'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('email')), 'user@test.com');
  await tester.enterText(find.byKey(Key('password')), 'Test123!');
  await tester.tap(find.text('Register'));
  await tester.pumpAndSettle();

  // Verify pending approval screen
  expect(find.text('Awaiting Approval'), findsOneWidget);

  // Admin approves (simulate via API)
  await approveUser('user@test.com');

  // User logs in
  await tester.restart();
  await login('user@test.com', 'Test123!');

  // Verify home screen
  expect(find.byType(HomePage), findsOneWidget);
});
```

#### 2. Daily Report Submission

```dart
testWidgets('Create and submit daily report', (WidgetTester tester) async {
  await setupAuthenticatedUser(tester);

  // Navigate to report form
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Fill deed values
  await tester.tap(find.byKey(Key('fajr_toggle')));
  await tester.tap(find.byKey(Key('dhuhr_toggle')));
  // ... fill other deeds

  // Save as draft
  await tester.tap(find.text('Save Draft'));
  await tester.pumpAndSettle();
  expect(find.text('Draft saved'), findsOneWidget);

  // Edit draft
  await tester.tap(find.byKey(Key('edit_draft_button')));
  await tester.pumpAndSettle();

  // Submit report
  await tester.tap(find.text('Submit Report'));
  await tester.pumpAndSettle();

  // Verify confirmation
  expect(find.text('Report submitted successfully'), findsOneWidget);
  expect(find.byType(ReportDetailScreen), findsOneWidget);
});
```

#### 3. Penalty Calculation

```dart
test('Penalty calculation end-to-end', () async {
  // Setup: User misses deadline
  final user = await createTestUser({ membership_status: 'exclusive' });
  final yesterday = DateTime.now().subtract(Duration(days: 1));

  // Don't submit report for yesterday
  // Wait for penalty calculation cron (12 PM)
  await runPenaltyCalculationJob();

  // Verify penalty created
  final penalties = await getPenalties(user.id);
  expect(penalties.length).toBe(1);
  expect(penalties[0].amount).toBe(50000); // Full 10 deeds missed

  // Verify notification sent
  final notifications = await getNotifications(user.id);
  expect(notifications.some(n => n.type === 'penalty_incurred')).toBe(true);

  // Verify user balance updated
  const stats = await getUserStatistics(user.id);
  expect(stats.penalty_balance).toBe(50000);
});
```

#### 4. Payment Flow

```dart
testWidgets('Submit and approve payment', (WidgetTester tester) async {
  await setupUserWithPenalty(tester);

  // User submits payment
  await tester.tap(find.text('Payments'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Submit Payment'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('amount')), '10000');
  await selectPaymentMethod('M-Pesa');
  await tester.enterText(find.byKey(Key('reference')), 'ABC123');

  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();

  expect(find.text('Payment submitted'), findsOneWidget);

  // Cashier approves (switch user context)
  await loginAsCashier(tester);
  await tester.tap(find.text('Pending Payments'));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(Key('approve_payment_button')));
  await tester.pumpAndSettle();

  // Verify payment approved and balance updated
  expect(find.text('Payment approved'), findsOneWidget);
});
```

#### 5. Excuse Submission & Approval

```dart
testWidgets('Excuse request flow', (WidgetTester tester) async {
  await setupAuthenticatedUser(tester);

  // Enable excuse mode
  await tester.tap(find.byKey(Key('excuse_mode_toggle')));
  await tester.pumpAndSettle();

  // Submit excuse
  await tester.tap(find.text('Submit Excuse'));
  await tester.pumpAndSettle();

  await selectDate('2025-10-20');
  await selectDeeds(['fajr', 'dhuhr']);
  await tester.enterText(find.byKey(Key('reason')), 'Was traveling');

  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();

  // Supervisor approves
  await loginAsSupervisor(tester);
  await tester.tap(find.text('Pending Excuses'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Approve'));
  await tester.pumpAndSettle();

  // Verify penalty waived
  const penalties = await getPenalties(userId, { status: 'waived' });
  expect(penalties.length).toBeGreaterThan(0);
});
```

**E2E Testing Tools:**
- **Flutter Integration Test**: Device/emulator testing
- **Patrol**: Advanced Flutter E2E testing
- **Appium**: Cross-platform mobile testing
- **Firebase Test Lab**: Cloud-based device testing

## Performance Testing

### Load Testing

Test system behavior under high concurrent usage.

**Scenarios:**

1. **Peak Report Submission (11:50 AM - 12:10 PM)**
```javascript
// Artillery load test configuration
config:
  target: 'https://api.gooddeeds.app'
  phases:
    - duration: 60
      arrivalRate: 100  # 100 users per second
      name: "Peak time simulation"

scenarios:
  - name: "Submit Report"
    flow:
      - post:
          url: "/api/reports"
          headers:
            Authorization: "Bearer {{ token }}"
          json:
            date: "2025-10-21"
            deed_values: { /* ... */ }
            deed_total: 8.5
            status: "submitted"
```

2. **Notification Delivery (1000 concurrent users)**
```javascript
scenarios:
  - name: "Mass Notification Send"
    flow:
      - post:
          url: "/api/admin/notifications/send"
          json:
            user_ids: ["user-1", "user-2", ..., "user-1000"]
            type: "deadline_reminder"
```

3. **Leaderboard Calculation**
```sql
-- Test leaderboard query with 10,000 users
EXPLAIN ANALYZE
SELECT u.id, u.full_name,
       COALESCE(s.total_deeds_submitted, 0) as total_deeds,
       COALESCE(s.current_streak_days, 0) as streak
FROM users u
LEFT JOIN user_statistics s ON u.id = s.user_id
WHERE u.account_status = 'active'
ORDER BY total_deeds DESC, streak DESC
LIMIT 100;
-- Target: < 100ms execution time
```

**Performance Targets:**

| Endpoint | Response Time | Throughput |
|----------|--------------|------------|
| GET /api/reports | < 200ms | 1000 req/s |
| POST /api/reports | < 500ms | 500 req/s |
| GET /api/statistics | < 300ms | 800 req/s |
| POST /api/payments | < 1000ms | 100 req/s |
| Leaderboard query | < 100ms | 500 req/s |

**Tools:**
- **Artillery**: Load testing framework
- **k6**: Performance testing tool
- **Apache JMeter**: Load and performance testing

### Database Performance

Test query performance with large datasets.

**Test Cases:**

1. **Large Report Dataset (100,000+ reports)**
```sql
-- Test query performance
SELECT * FROM reports
WHERE user_id = 'user-123'
  AND date >= '2025-01-01'
ORDER BY date DESC;

-- Optimize with index
CREATE INDEX idx_reports_user_date_desc
ON reports(user_id, date DESC);
```

2. **Leaderboard Calculation (10,000+ users)**
```sql
-- Test and optimize
EXPLAIN ANALYZE
SELECT /* leaderboard query */;

-- Add materialized view for caching
CREATE MATERIALIZED VIEW leaderboard_cache AS
SELECT /* leaderboard query */;

REFRESH MATERIALIZED VIEW leaderboard_cache;
```

3. **Statistics Aggregation**
```sql
-- Test aggregate queries
SELECT
  COUNT(*) as total_reports,
  SUM(deed_total) as total_deeds,
  AVG(deed_total) as avg_deeds
FROM reports
WHERE user_id = 'user-123'
  AND date >= '2025-01-01';
```

**Tools:**
- **EXPLAIN ANALYZE**: Query execution plans
- **pg_stat_statements**: Query performance tracking
- **Supabase Dashboard**: Performance monitoring

## User Acceptance Testing (UAT)

### Test Groups

- **Size**: 5-10 beta testers from target audience
- **Diversity**: Mix of membership statuses (new, exclusive, legacy)
- **Platforms**: Both iOS and Android devices
- **Duration**: 2-4 weeks before launch

### Testing Checklist

**Core Features:**
- [ ] User registration and approval process
- [ ] Daily report submission (draft and submit)
- [ ] Penalty calculation accuracy
- [ ] Payment submission and approval
- [ ] Excuse mode and approval workflow
- [ ] Notifications (push and in-app)
- [ ] Leaderboard and statistics display
- [ ] Offline functionality

**UI/UX Evaluation:**
- [ ] Navigation is intuitive
- [ ] Forms are easy to complete
- [ ] Error messages are clear
- [ ] Loading states are appropriate
- [ ] Visual design is appealing
- [ ] Accessibility features work

**Feedback Collection:**
- User interviews (30-minute sessions)
- In-app feedback form
- Bug reporting channel (email/Slack)
- Weekly survey on experience

**Success Criteria:**
- 90% of testers can complete core tasks without help
- Average task completion time meets targets
- No critical bugs reported
- Overall satisfaction score > 4/5

## Coverage Targets

### Code Coverage Goals

| Test Type | Target Coverage |
|-----------|----------------|
| Backend Unit Tests | 80%+ |
| Frontend Unit Tests | 70%+ |
| Integration Tests | Key API endpoints |
| E2E Tests | Critical user flows |
| Overall Coverage | 75%+ |

### Coverage Reporting

```bash
# Backend coverage (Jest)
npm test -- --coverage

# Frontend coverage (Flutter)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# View coverage report
open coverage/html/index.html
```

## Testing Tools Summary

### Backend
- **Jest**: Unit testing framework
- **Supertest**: HTTP assertion library
- **pg-mock**: Mock PostgreSQL queries
- **Postman/Newman**: API testing

### Frontend
- **Flutter Test**: Widget and unit testing
- **Mockito**: Dependency mocking
- **Bloc Test**: State management testing
- **Patrol/Integration Test**: E2E testing

### Performance
- **Artillery**: Load testing
- **k6**: Performance testing
- **PostgreSQL EXPLAIN**: Query analysis

### Monitoring
- **Sentry**: Error tracking
- **Firebase Analytics**: User behavior
- **Supabase Dashboard**: Database monitoring

## Continuous Integration

### Automated Test Pipeline

```yaml
# GitHub Actions workflow
name: Test Pipeline

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run unit tests
        run: npm test
      - name: Run integration tests
        run: npm run test:integration

  frontend-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
      - name: Run tests
        run: flutter test
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  e2e-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run E2E tests
        run: flutter drive --target=test_driver/app.dart
```

## Best Practices

1. **Write Tests First (TDD)**: Test-driven development for critical logic
2. **Keep Tests Fast**: Unit tests should run in < 1 second
3. **Mock External Dependencies**: Isolate tests from external services
4. **Test Edge Cases**: Cover boundary conditions and error scenarios
5. **Maintain Tests**: Update tests when code changes
6. **Review Coverage**: Monitor and improve test coverage regularly
7. **Automate Everything**: Run tests automatically on every commit

---

## Related Documentation

- [04-offline-support.md](./04-offline-support.md) - Testing offline functionality
- [08-edge-cases.md](./08-edge-cases.md) - Edge cases to test
- [06-deployment.md](./06-deployment.md) - CI/CD pipeline with testing

---

**Last Updated**: 2025-10-22
**Version**: 1.0
