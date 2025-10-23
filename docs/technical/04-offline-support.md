# Offline Support

## Overview

The Good Deeds Tracking App provides robust offline functionality to ensure users can continue working even when network connectivity is limited or unavailable. The offline-first strategy focuses on draft management and local data caching, with intelligent synchronization when connectivity is restored.

## Offline Capabilities

### Allowed Actions (Offline)

When the device is offline, users can perform the following operations:

- **View cached reports**: Access previously loaded report history
- **Create/edit draft reports**: Work on daily deed reports without connection
- **View cached statistics**: Review personal statistics and metrics
- **View rules & policies**: Access cached app documentation
- **View cached notifications**: Read previously received notifications

### Restricted Actions (Require Connection)

The following operations require an active internet connection:

- **Submit reports**: Final report submission requires server validation
- **Submit payments**: Payment claims must be processed immediately
- **Submit excuses**: Excuse requests need supervisor approval
- **View real-time leaderboard**: Rankings require current data
- **Receive new notifications**: Push notifications need active connection
- **View other users' data**: Supervisor access requires real-time data

## Local Storage Strategy

### Storage Technology

The app uses Flutter's local storage capabilities for offline data persistence:

- **Hive**: Lightweight, NoSQL database for Flutter (primary choice)
  - Fast key-value storage
  - Encrypted boxes for sensitive data
  - Type-safe with generated adapters
  - Minimal dependencies

- **SQLite** (Alternative): For complex queries and relationships
  - sqflite package for Flutter
  - Relational data structure
  - SQL query support
  - Larger storage capacity

### Data Storage Schema

```dart
// Draft Report Model
class DraftReport {
  String id;
  String userId;
  DateTime date;
  Map<String, dynamic> deedValues;
  DateTime lastModified;
  bool isSynced;
  String syncStatus; // 'pending', 'syncing', 'synced', 'failed'
}

// Cached Data Model
class CachedData {
  String key;
  dynamic value;
  DateTime cachedAt;
  DateTime expiresAt;
}
```

### Storage Limits

- **Draft Reports**: Maximum 30 days of drafts
- **Cached Reports**: Last 90 days of submitted reports
- **Statistics**: Current month + previous 2 months
- **Notifications**: Last 50 notifications
- **Total Storage**: ~10-20 MB per user

## Sync Mechanism

### Connection Detection

```dart
// Monitor connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectionStatus {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
```

### Sync Strategy

**On Connection Restored:**

```javascript
async function syncOfflineData() {
  // 1. Check for pending draft reports
  const pendingDrafts = await getLocalDrafts({ isSynced: false });

  // 2. Attempt to sync drafts to server
  for (const draft of pendingDrafts) {
    try {
      await syncDraftToServer(draft);
    } catch (error) {
      // Mark as failed, will retry on next sync
      await markDraftSyncFailed(draft.id, error.message);
    }
  }

  // 3. Resolve conflicts (server version wins if both exist)
  await resolveConflicts();

  // 4. Fetch latest user statistics
  const stats = await fetchUserStatistics();
  await cacheStatistics(stats);

  // 5. Fetch new notifications
  const notifications = await fetchNotifications({ since: lastSyncTime });
  await cacheNotifications(notifications);

  // 6. Update cached data
  await updateCachedReports();

  // 7. Show sync success/failure message
  showSyncStatus();
}
```

### Auto-Sync Triggers

- **On App Launch**: Check and sync pending data
- **Connection Restored**: Immediate sync attempt
- **Background Sync**: Periodic sync every 15 minutes (when app active)
- **Before Submit**: Ensure all drafts synced before final submission

## Conflict Resolution

### Scenario 1: Draft Edited Offline, Grace Period Expired

**Problem**: User edits a draft while offline, but the grace period for that date has ended.

**Resolution:**
```javascript
// Check if draft is still valid
async function validateDraftBeforeSync(draft) {
  const graceperiodHours = await getSetting('grace_period_hours');
  const gracePeriodEnd = moment(draft.date)
    .add(1, 'day')
    .add(graceperiodHours, 'hours');

  if (moment().isAfter(gracePeriodEnd)) {
    // Grace period has ended
    return {
      valid: false,
      reason: 'grace_period_expired',
      message: 'Grace period has ended for this date'
    };
  }

  return { valid: true };
}
```

**User Experience:**
- Show warning: "Grace period has ended for this date"
- Offer options:
  1. **Discard draft**: Remove the expired draft
  2. **Contact admin**: Request special permission for past date submission
- **Do not sync expired drafts** automatically

### Scenario 2: Duplicate Report (Created Offline and Online)

**Problem**: User creates a draft offline, then creates another report for the same date online before syncing.

**Resolution:**
```javascript
async function resolveConflictingReports(localDraft, serverReport) {
  // Server version always wins
  if (serverReport.status === 'submitted') {
    // Delete local draft, keep server version
    await deleteLocalDraft(localDraft.id);
    return {
      action: 'server_wins',
      message: 'Report already submitted online'
    };
  }

  // Compare timestamps
  if (localDraft.lastModified > serverReport.updated_at) {
    // Local changes are newer, merge values
    return {
      action: 'merge',
      data: mergeDraftValues(localDraft, serverReport)
    };
  }

  // Server version is newer
  return {
    action: 'discard_local',
    message: 'Server version is more recent'
  };
}
```

### Scenario 3: Network Error During Submit

**Problem**: User attempts to submit report, but network fails mid-request.

**Resolution:**
```javascript
try {
  await submitReport(reportData);
} catch (error) {
  if (error.type === 'NetworkError') {
    // Save as draft with pending status
    await saveDraftLocally(reportData, {
      status: 'pending_submission',
      error: error.message
    });

    // Queue for retry
    await addToSyncQueue({
      type: 'submit_report',
      data: reportData,
      retryCount: 0,
      maxRetries: 3
    });

    // Show user-friendly message
    showMessage({
      type: 'warning',
      title: 'Connection Lost',
      message: 'Your report has been saved as draft and will be submitted automatically when connection is restored.'
    });
  }
}
```

## Draft Management

### Auto-Save Functionality

```dart
// Auto-save draft every 30 seconds
class DraftAutoSave {
  Timer? _timer;
  final int autoSaveInterval = 30; // seconds

  void startAutoSave(Report draft) {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: autoSaveInterval),
      (_) => saveDraftLocally(draft)
    );
  }

  void stopAutoSave() {
    _timer?.cancel();
  }
}
```

### Draft Expiration

**Trigger**: Daily cleanup job (runs at 12:30 PM after grace period)

```javascript
async function cleanupExpiredDrafts() {
  const gracePeriodHours = await getSetting('grace_period_hours');

  // Calculate grace period end for yesterday
  const yesterday = moment().subtract(1, 'day').startOf('day');
  const gracePeriodEnd = yesterday.add(gracePeriodHours, 'hours');

  if (moment().isAfter(gracePeriodEnd)) {
    // Delete all draft reports for yesterday or earlier
    await deleteDrafts({
      date: { lte: yesterday.toDate() },
      status: 'draft'
    });

    console.log('Expired drafts cleaned up');
  }
}
```

## Queue for Pending Operations

### Operation Queue Structure

```javascript
class SyncQueue {
  constructor() {
    this.queue = [];
    this.isProcessing = false;
  }

  async addOperation(operation) {
    this.queue.push({
      id: generateId(),
      type: operation.type,
      data: operation.data,
      timestamp: new Date(),
      retryCount: 0,
      maxRetries: 3,
      status: 'pending'
    });

    await this.saveQueue();
    this.processQueue();
  }

  async processQueue() {
    if (this.isProcessing || this.queue.length === 0) return;

    this.isProcessing = true;

    while (this.queue.length > 0) {
      const operation = this.queue[0];

      try {
        await this.executeOperation(operation);
        this.queue.shift(); // Remove from queue
      } catch (error) {
        operation.retryCount++;

        if (operation.retryCount >= operation.maxRetries) {
          // Move to failed queue
          await this.moveToFailedQueue(operation, error);
          this.queue.shift();
        } else {
          // Retry later with exponential backoff
          await this.sleep(Math.pow(2, operation.retryCount) * 1000);
        }
      }

      await this.saveQueue();
    }

    this.isProcessing = false;
  }
}
```

## Network Detection and Retry Logic

### Retry Strategy

```dart
class RetryStrategy {
  final int maxRetries = 3;
  final int baseDelay = 1000; // 1 second

  Future<T> executeWithRetry<T>(
    Future<T> Function() operation,
    {bool exponentialBackoff = true}
  ) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;

        if (attempts >= maxRetries) {
          throw error;
        }

        // Calculate delay
        final delay = exponentialBackoff
          ? baseDelay * pow(2, attempts)
          : baseDelay;

        await Future.delayed(Duration(milliseconds: delay));
      }
    }

    throw Exception('Max retries exceeded');
  }
}
```

### Network-Aware Operations

```dart
class NetworkAwareOperation {
  final ConnectivityService _connectivity;
  final RetryStrategy _retry;

  Future<void> performOperation(Function operation) async {
    // Check connectivity first
    final hasConnection = await _connectivity.hasInternetConnection();

    if (!hasConnection) {
      throw NetworkException('No internet connection');
    }

    // Execute with retry
    return await _retry.executeWithRetry(() => operation());
  }
}
```

## Offline Indicators in UI

### Connection Status Banner

```dart
class OfflineIndicator extends StatelessWidget {
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Offline Mode - Changes will sync when connection is restored',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
```

### Sync Status Indicators

- **Synced**: Green checkmark icon
- **Pending Sync**: Orange clock icon with animation
- **Sync Failed**: Red error icon with retry button
- **Syncing**: Blue spinner animation

### Draft Status Badges

```dart
Widget buildDraftStatusBadge(String syncStatus) {
  switch (syncStatus) {
    case 'synced':
      return Chip(
        label: Text('Synced'),
        avatar: Icon(Icons.check_circle, color: Colors.green),
        backgroundColor: Colors.green.shade50,
      );
    case 'pending':
      return Chip(
        label: Text('Pending Sync'),
        avatar: Icon(Icons.schedule, color: Colors.orange),
        backgroundColor: Colors.orange.shade50,
      );
    case 'failed':
      return Chip(
        label: Text('Sync Failed'),
        avatar: Icon(Icons.error, color: Colors.red),
        backgroundColor: Colors.red.shade50,
      );
    default:
      return SizedBox.shrink();
  }
}
```

## Best Practices

### 1. Minimize Offline Data Size
- Cache only essential data
- Implement pagination for large datasets
- Compress cached data when possible
- Regular cleanup of expired data

### 2. User Communication
- Always show offline status clearly
- Inform users about pending operations
- Provide manual sync option
- Display last sync timestamp

### 3. Data Integrity
- Validate data before saving locally
- Implement conflict resolution logic
- Use transactions for atomic operations
- Backup local data before sync

### 4. Performance Optimization
- Use background threads for sync operations
- Implement debouncing for auto-save
- Batch multiple operations when possible
- Cancel outdated sync requests

### 5. Error Handling
- Graceful degradation when offline
- Clear error messages for users
- Log sync failures for debugging
- Implement fallback strategies

## Testing Offline Functionality

### Test Scenarios

1. **Create draft while offline, sync when online**
2. **Edit draft offline, submit when connection restored**
3. **Handle grace period expiration during offline mode**
4. **Simulate network interruption during submit**
5. **Test conflict resolution with duplicate reports**
6. **Verify auto-save functionality**
7. **Test queue retry logic with multiple failures**
8. **Validate draft cleanup after grace period**

### Testing Tools

- **Flutter Connectivity Plus**: Test connectivity changes
- **Mock HTTP Client**: Simulate network failures
- **Integration Tests**: End-to-end offline scenarios
- **Device Network Settings**: Real-world testing

---

## Related Documentation

- [03-database-schema.md](./03-database-schema.md) - Database structure for reports and drafts
- [08-edge-cases.md](./08-edge-cases.md) - Additional edge case handling
- [05-testing.md](./05-testing.md) - Testing strategies including offline tests
- [Features: Offline Functionality](../features/06-offline-functionality.md) - User-facing offline features

---

**Last Updated**: 2025-10-22
**Version**: 1.0
