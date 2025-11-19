# SQL Migration Fixes

## Issues Found & Fixed

### Issue 1: Leaderboard Function - Type Mismatch
**Error:** "Returned type bigint does not match expected type integer in column 1"

**Problem:** `ROW_NUMBER()` returns `BIGINT` but the function declared `rank` as `INTEGER`.

**Fix:** Changed the return type of `rank` from `INTEGER` to `BIGINT`.

```sql
-- Before
RETURNS TABLE (
  rank INTEGER,  -- ❌ Wrong type
  ...
)

-- After
RETURNS TABLE (
  rank BIGINT,   -- ✅ Correct type
  ...
)
```

---

### Issue 2: Leaderboard Function - CTE Naming Conflict
**Error:** "Column reference 'user_id' is ambiguous"

**Problem:** The CTE was named `user_tags` which conflicts with the actual table name `user_tags`, causing ambiguity.

**Fix:** Renamed the CTE from `user_tags` to `user_special_tags` and updated all references.

```sql
-- Before
user_tags AS (  -- ❌ Conflicts with table name
  SELECT
    ut.user_id,
    ...
  FROM user_tags ut
  ...
)
...
LEFT JOIN user_tags ut ON ut.user_id = uds.user_id  -- ❌ Ambiguous

-- After
user_special_tags AS (  -- ✅ Unique name
  SELECT
    ut.user_id,
    ...
  FROM user_tags ut
  ...
)
...
LEFT JOIN user_special_tags ust ON ust.user_id = uds.user_id  -- ✅ Clear
```

---

### Issue 3: Dart Model Mapping
**Problem:** The SQL function returns different field names than what the Dart model expects.

**SQL Returns:**
- `rank` (BIGINT)
- `user_id` (UUID)
- `user_name` (TEXT)
- `total_deeds` (DECIMAL)
- `average_deeds` (DECIMAL)
- `special_tags` (JSONB)
- `photo_url` (TEXT)
- `membership_status` (TEXT)

**Model Expects:**
- `rank` (int)
- `userId` (String)
- `fullName` (String)
- `profilePhotoUrl` (String)
- `membershipStatus` (String)
- `averageDeeds` (double)
- `complianceRate` (double)
- `achievementTags` (List<String>)
- `hasFajrChampion` (bool)
- `currentStreak` (int)

**Fix:** Updated the datasource to map the SQL output to the expected model format.

```dart
// Map SQL function output to model fields
return LeaderboardEntryModel.fromJson({
  'rank': (data['rank'] as num).toInt(),
  'userId': data['user_id'],
  'fullName': data['user_name'],
  'profilePhotoUrl': data['photo_url'],
  'membershipStatus': data['membership_status'] ?? 'new',
  'averageDeeds': (data['average_deeds'] as num?)?.toDouble() ?? 0.0,
  'complianceRate': 0.0, // Not in SQL, calculate separately if needed
  'achievementTags': (data['special_tags'] as List?)
      ?.map((tag) => tag['name'] as String)
      .toList() ?? [],
  'hasFajrChampion': (data['special_tags'] as List?)
      ?.any((tag) => tag['tag_key'] == 'fajr_champion') ?? false,
  'currentStreak': 0, // Not in SQL, calculate separately if needed
});
```

---

## Files Updated

1. **`supabase/migrations/20250119_create_supervisor_functions.sql`**
   - Changed `rank` type from `INTEGER` to `BIGINT`
   - Renamed CTE from `user_tags` to `user_special_tags`
   - Updated all JOIN references

2. **`lib/features/supervisor/data/datasources/supervisor_remote_datasource.dart`**
   - Added field mapping in `getLeaderboard()` method
   - Handles JSONB `special_tags` parsing
   - Converts SQL types to Dart types properly

---

## How to Apply

### Step 1: Drop Old Function (if exists)
Run this in your Supabase SQL Editor first:

```sql
DROP FUNCTION IF EXISTS public.get_leaderboard_rankings(TEXT, INTEGER);
```

### Step 2: Apply Updated Migration
Execute the updated `20250119_create_supervisor_functions.sql` file in your Supabase SQL Editor.

### Step 3: Test
```sql
-- Should work without errors now
SELECT * FROM get_leaderboard_rankings('weekly', 10);
SELECT * FROM get_users_at_risk(100000);
```

---

## Verification

After applying the fixes, test in your app:

1. ✅ Navigate to Leaderboard page
2. ✅ Switch between Daily/Weekly/Monthly/All Time tabs
3. ✅ View leaderboard entries (should show ranks and user info)
4. ✅ Navigate to Users at Risk page
5. ✅ View users with high balances
6. ✅ Adjust threshold slider and refresh

Both pages should now load without PostgreSQL errors!
