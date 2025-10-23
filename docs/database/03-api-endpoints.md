# Backend API Endpoints

This document provides comprehensive technical specifications for all REST API endpoints in the Sabiquun application, including authentication, request/response formats, error codes, and scheduled tasks.

## Table of Contents

- [Overview](#overview)
- [API Standards](#api-standards)
- [Authentication](#authentication)
- [Authentication Endpoints](#authentication-endpoints)
- [User Management Endpoints (Admin)](#user-management-endpoints-admin)
- [Deed Template Endpoints (Admin)](#deed-template-endpoints-admin)
- [Report Endpoints](#report-endpoints)
- [Report Management Endpoints (Admin)](#report-management-endpoints-admin)
- [Penalty Endpoints](#penalty-endpoints)
- [Penalty Management Endpoints (Admin/Cashier)](#penalty-management-endpoints-admincashier)
- [Payment Endpoints](#payment-endpoints)
- [Payment Management Endpoints (Admin/Cashier)](#payment-management-endpoints-admincashier)
- [Excuse Endpoints](#excuse-endpoints)
- [Excuse Management Endpoints (Supervisor/Admin)](#excuse-management-endpoints-supervisoradmin)
- [Notification Endpoints](#notification-endpoints)
- [Notification Management Endpoints (Admin/Supervisor)](#notification-management-endpoints-adminsupervisor)
- [Settings Endpoints (Admin)](#settings-endpoints-admin)
- [Rest Days Endpoints](#rest-days-endpoints)
- [Leaderboard Endpoints](#leaderboard-endpoints)
- [Leaderboard Management Endpoints (Supervisor/Admin)](#leaderboard-management-endpoints-supervisoradmin)
- [Analytics Endpoints (Admin/Supervisor)](#analytics-endpoints-adminsupervisor)
- [Audit Log Endpoints (Admin)](#audit-log-endpoints-admin)
- [Content Management Endpoints](#content-management-endpoints)
- [System Endpoints](#system-endpoints)
- [Cron Jobs & Scheduled Tasks](#cron-jobs--scheduled-tasks)
- [Error Codes](#error-codes)
- [Rate Limiting](#rate-limiting)

---

## Overview

The Sabiquun API follows RESTful principles with JSON request/response bodies. All endpoints require authentication except for registration, login, and public content.

**Base URL:** `https://api.sabiquun.app` (production)

**API Version:** v1

---

## API Standards

### Request Format

- **Content-Type:** `application/json`
- **Accept:** `application/json`
- **Authorization:** `Bearer {access_token}` (for authenticated endpoints)

### Response Format

All responses follow a consistent structure:

**Success Response:**
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { ... }
  }
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | OK - Request succeeded |
| 201 | Created - Resource created successfully |
| 204 | No Content - Request succeeded with no response body |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource conflict (duplicate) |
| 422 | Unprocessable Entity - Validation failed |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

---

## Authentication

The API uses **JWT (JSON Web Tokens)** for authentication.

### Authentication Flow

1. User logs in with credentials
2. Server returns JWT access token (expires in 24 hours)
3. Client includes token in Authorization header: `Bearer {token}`
4. Server validates token on each request

### Token Structure

```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "role": "user",
  "membership_status": "exclusive",
  "iat": 1634567890,
  "exp": 1634654290
}
```

---

## Authentication Endpoints

### Register User

Creates a new user account (pending admin approval).

```
POST /api/auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "name": "Ahmed Hassan",
  "phone": "+252612345678"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "Ahmed Hassan",
      "phone": "+252612345678",
      "role": "user",
      "account_status": "pending",
      "membership_status": "new",
      "created_at": "2025-10-22T10:00:00Z"
    }
  },
  "message": "Registration successful. Awaiting admin approval."
}
```

**Validation Rules:**
- Email: Valid email format, unique
- Password: Min 8 characters, must include uppercase, lowercase, number
- Name: Required, 2-255 characters
- Phone: Optional, valid phone format

---

### Login

Authenticates user and returns JWT token.

```
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 86400,
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "Ahmed Hassan",
      "role": "user",
      "account_status": "active",
      "membership_status": "exclusive"
    }
  }
}
```

**Error (401):**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  }
}
```

---

### Logout

Invalidates the current session token.

```
POST /api/auth/logout
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### Forgot Password

Initiates password reset process.

```
POST /api/auth/forgot-password
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset instructions sent to your email"
}
```

---

### Reset Password

Resets password using token from email.

```
POST /api/auth/reset-password
```

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "new_password": "NewSecurePassword123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset successful. Please login with your new password."
}
```

---

### Get Current User

Returns authenticated user's information.

```
GET /api/auth/me
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "Ahmed Hassan",
      "phone": "+252612345678",
      "photo_url": "https://cdn.sabiquun.app/photos/user.jpg",
      "role": "user",
      "membership_status": "exclusive",
      "account_status": "active",
      "excuse_mode": false,
      "created_at": "2024-01-15T10:00:00Z"
    },
    "statistics": {
      "total_deeds": 285.5,
      "average_daily_deeds": 9.5,
      "current_penalty_balance": 15000,
      "current_streak_days": 12,
      "fajr_completion_rate": 92.5
    }
  }
}
```

---

### Update Profile

Updates user profile information.

```
PUT /api/auth/update-profile
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "Ahmed Hassan Al-Somali",
  "phone": "+252612345678",
  "photo_url": "https://cdn.sabiquun.app/photos/new-photo.jpg"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": { ... }
  },
  "message": "Profile updated successfully"
}
```

---

### Change Password

Changes user's password.

```
PUT /api/auth/change-password
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewPassword123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

## User Management Endpoints (Admin)

**Required Role:** `admin`

### List All Users

Returns paginated list of users with optional filters.

```
GET /api/admin/users?page=1&limit=20&role=user&account_status=active&search=ahmed
Authorization: Bearer {admin_token}
```

**Query Parameters:**
- `page` (integer, default: 1)
- `limit` (integer, default: 20, max: 100)
- `role` (string: user, supervisor, cashier, admin)
- `account_status` (string: pending, active, suspended, auto_deactivated)
- `membership_status` (string: new, exclusive, legacy)
- `search` (string: search by name or email)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "uuid",
        "email": "user@example.com",
        "name": "Ahmed Hassan",
        "role": "user",
        "account_status": "active",
        "membership_status": "exclusive",
        "current_penalty_balance": 15000,
        "created_at": "2024-01-15T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "pages": 8
    }
  }
}
```

---

### Get User Details

Returns detailed information about a specific user.

```
GET /api/admin/users/:id
Authorization: Bearer {admin_token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "statistics": { ... },
    "recent_reports": [ ... ],
    "recent_penalties": [ ... ],
    "recent_payments": [ ... ]
  }
}
```

---

### Update User

Updates user information.

```
PUT /api/admin/users/:id
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "name": "Updated Name",
  "phone": "+252612345678",
  "email": "newemail@example.com"
}
```

---

### Delete User

Permanently deletes a user account.

```
DELETE /api/admin/users/:id
Authorization: Bearer {admin_token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

---

### Approve Pending User

Approves a pending user registration.

```
POST /api/admin/users/:id/approve
Authorization: Bearer {admin_token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "User approved successfully"
}
```

---

### Reject Pending User

Rejects a pending user registration.

```
POST /api/admin/users/:id/reject
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "reason": "Invalid credentials provided"
}
```

---

### Suspend User

Suspends an active user account.

```
POST /api/admin/users/:id/suspend
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "reason": "Violation of terms of service"
}
```

---

### Reactivate User

Reactivates a suspended or auto-deactivated user.

```
POST /api/admin/users/:id/reactivate
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "reason": "Penalty balance cleared"
}
```

---

### Change User Role

Changes a user's role.

```
PUT /api/admin/users/:id/role
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "role": "supervisor"
}
```

**Valid Roles:** `user`, `supervisor`, `cashier`, `admin`

---

### Upgrade Membership Status

Manually upgrades user's membership status.

```
PUT /api/admin/users/:id/membership
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "membership_status": "legacy",
  "reason": "Long-term member reward"
}
```

---

## Deed Template Endpoints (Admin)

**Required Role:** `admin`

### List All Deed Templates

```
GET /api/admin/deed-templates
Authorization: Bearer {admin_token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "templates": [
      {
        "id": "uuid",
        "deed_name": "Fajr Prayer",
        "deed_key": "fajr_prayer",
        "category": "faraid",
        "value_type": "binary",
        "sort_order": 1,
        "is_active": true,
        "is_system_default": true
      }
    ]
  }
}
```

---

### Get Template Details

```
GET /api/admin/deed-templates/:id
Authorization: Bearer {admin_token}
```

---

### Create Deed Template

```
POST /api/admin/deed-templates
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "deed_name": "Night Prayer",
  "deed_key": "night_prayer",
  "category": "sunnah",
  "value_type": "binary",
  "sort_order": 11
}
```

---

### Update Deed Template

```
PUT /api/admin/deed-templates/:id
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "deed_name": "Updated Name",
  "sort_order": 5
}
```

---

### Delete Deed Template

```
DELETE /api/admin/deed-templates/:id
Authorization: Bearer {admin_token}
```

**Note:** Cannot delete system default templates (`is_system_default: true`)

---

### Reorder Templates

Updates sort order for multiple templates.

```
PUT /api/admin/deed-templates/reorder
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "templates": [
    { "id": "uuid1", "sort_order": 1 },
    { "id": "uuid2", "sort_order": 2 },
    { "id": "uuid3", "sort_order": 3 }
  ]
}
```

---

## Report Endpoints

**Required Role:** `user` (any authenticated user)

### Get User's Reports

```
GET /api/reports?start_date=2025-10-01&end_date=2025-10-31&status=submitted
Authorization: Bearer {token}
```

**Query Parameters:**
- `start_date` (date)
- `end_date` (date)
- `status` (string: draft, submitted)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "reports": [
      {
        "id": "uuid",
        "report_date": "2025-10-21",
        "total_deeds": 9.5,
        "sunnah_count": 4.5,
        "faraid_count": 5.0,
        "status": "submitted",
        "submitted_at": "2025-10-21T22:30:00Z"
      }
    ]
  }
}
```

---

### Get Specific Report

```
GET /api/reports/:id
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "report": {
      "id": "uuid",
      "report_date": "2025-10-21",
      "total_deeds": 9.5,
      "status": "submitted",
      "submitted_at": "2025-10-21T22:30:00Z",
      "deed_entries": [
        {
          "deed_template_id": "uuid",
          "deed_name": "Fajr Prayer",
          "deed_value": 1.0,
          "category": "faraid"
        },
        {
          "deed_template_id": "uuid",
          "deed_name": "Sunnah Prayers",
          "deed_value": 0.5,
          "category": "sunnah"
        }
      ]
    }
  }
}
```

---

### Create Report (Draft)

```
POST /api/reports
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "report_date": "2025-10-21",
  "deed_entries": [
    {
      "deed_template_id": "uuid",
      "deed_value": 1.0
    },
    {
      "deed_template_id": "uuid",
      "deed_value": 0.5
    }
  ]
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "report": {
      "id": "uuid",
      "report_date": "2025-10-21",
      "total_deeds": 9.5,
      "status": "draft"
    }
  },
  "message": "Draft report created successfully"
}
```

---

### Update Report (Draft Only)

```
PUT /api/reports/:id
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "deed_entries": [
    {
      "deed_template_id": "uuid",
      "deed_value": 1.0
    }
  ]
}
```

**Note:** Can only update reports with status 'draft'

---

### Submit Report

```
POST /api/reports/:id/submit
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "report": {
      "id": "uuid",
      "status": "submitted",
      "total_deeds": 9.5,
      "sunnah_count": 4.5,
      "faraid_count": 5.0,
      "submitted_at": "2025-10-21T22:30:00Z"
    }
  },
  "message": "Report submitted successfully"
}
```

---

### Delete Draft Report

```
DELETE /api/reports/:id
Authorization: Bearer {token}
```

**Note:** Can only delete draft reports

---

### Get Report for Specific Date

```
GET /api/reports/date/:date
Authorization: Bearer {token}
```

**Example:** `GET /api/reports/date/2025-10-21`

---

### Get User's Deed Statistics

```
GET /api/reports/statistics
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_deeds": 285.5,
    "total_reports_submitted": 30,
    "average_daily_deeds": 9.5,
    "best_streak_days": 15,
    "current_streak_days": 12,
    "fajr_completion_rate": 92.5,
    "faraid_completion_rate": 88.0,
    "sunnah_completion_rate": 75.5,
    "last_report_date": "2025-10-21"
  }
}
```

---

### Export Reports

```
POST /api/reports/export
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "start_date": "2025-10-01",
  "end_date": "2025-10-31",
  "format": "pdf"
}
```

**Formats:** `pdf`, `excel`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "download_url": "https://cdn.sabiquun.app/exports/report-uuid.pdf",
    "expires_at": "2025-10-22T10:00:00Z"
  }
}
```

---

## Report Management Endpoints (Admin)

**Required Role:** `admin`

### List All User Reports

```
GET /api/admin/reports?user_id=uuid&start_date=2025-10-01&status=submitted
Authorization: Bearer {admin_token}
```

---

### Get User's Reports

```
GET /api/admin/reports/user/:userId
Authorization: Bearer {admin_token}
```

---

### Edit Deed Value in Submitted Report

```
PUT /api/admin/reports/:id/edit-deed
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "deed_entry_id": "uuid",
  "new_value": 1.0,
  "reason": "User submitted incorrect value"
}
```

**Creates audit log entry**

---

## Penalty Endpoints

**Required Role:** `user` (any authenticated user)

### Get User's Penalties

```
GET /api/penalties?status=unpaid&start_date=2025-10-01
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "penalties": [
      {
        "id": "uuid",
        "amount": 15000,
        "date_incurred": "2025-10-15",
        "status": "unpaid",
        "paid_amount": 0
      }
    ],
    "summary": {
      "total_unpaid": 45000,
      "total_paid": 30000,
      "current_balance": 45000
    }
  }
}
```

---

### Get Current Balance

```
GET /api/penalties/balance
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "current_balance": 45000,
    "total_penalties_incurred": 75000,
    "total_penalties_paid": 30000,
    "auto_deactivation_threshold": 500000,
    "warning_threshold": 400000
  }
}
```

---

### Get Penalty History

```
GET /api/penalties/history?page=1&limit=20
Authorization: Bearer {token}
```

---

## Penalty Management Endpoints (Admin/Cashier)

**Required Role:** `admin` or `cashier`

### List All Penalties

```
GET /api/admin/penalties?user_id=uuid&status=unpaid
Authorization: Bearer {admin_token}
```

---

### Create Manual Penalty

```
POST /api/admin/penalties
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "user_id": "uuid",
  "amount": 10000,
  "date_incurred": "2025-10-21",
  "reason": "Manual adjustment"
}
```

---

### Update Penalty

```
PUT /api/admin/penalties/:id
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "amount": 12000,
  "reason": "Correction"
}
```

---

### Delete Penalty

```
DELETE /api/admin/penalties/:id
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "reason": "Entered in error"
}
```

---

### Waive Penalty

```
POST /api/admin/penalties/:id/waive
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "reason": "Exceptional circumstances"
}
```

---

## Payment Endpoints

**Required Role:** `user` (any authenticated user)

### Get User's Payments

```
GET /api/payments?status=approved&start_date=2025-10-01
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "payments": [
      {
        "id": "uuid",
        "amount": 30000,
        "payment_method": "ZAAD",
        "reference_number": "ZAAD123456",
        "status": "approved",
        "submitted_at": "2025-10-20T10:00:00Z",
        "reviewed_at": "2025-10-20T14:30:00Z"
      }
    ]
  }
}
```

---

### Submit Payment

```
POST /api/payments
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "amount": 30000,
  "payment_method": "ZAAD",
  "reference_number": "ZAAD123456",
  "payment_type": "partial"
}
```

**Payment Types:** `full`, `partial`

---

### Get Payment Details

```
GET /api/payments/:id
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "payment": {
      "id": "uuid",
      "amount": 30000,
      "payment_method": "ZAAD",
      "status": "approved",
      "applied_to_penalties": [
        {
          "penalty_id": "uuid",
          "amount_applied": 15000,
          "date_incurred": "2025-10-15"
        },
        {
          "penalty_id": "uuid",
          "amount_applied": 15000,
          "date_incurred": "2025-10-16"
        }
      ]
    }
  }
}
```

---

### Download Payment Receipt

```
GET /api/payments/receipt/:id
Authorization: Bearer {token}
```

**Response:** PDF file download

---

## Payment Management Endpoints (Admin/Cashier)

**Required Role:** `admin` or `cashier`

### List All Payments

```
GET /api/admin/payments?user_id=uuid&status=pending
Authorization: Bearer {admin_token}
```

---

### List Pending Payments

```
GET /api/admin/payments/pending
Authorization: Bearer {admin_token}
```

---

### Approve Payment

```
POST /api/admin/payments/:id/approve
Authorization: Bearer {admin_token}
```

**Triggers FIFO payment application algorithm**

---

### Reject Payment

```
POST /api/admin/payments/:id/reject
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "reason": "Invalid payment proof"
}
```

---

### Manually Clear Balance

```
POST /api/admin/payments/clear-balance
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "user_id": "uuid",
  "reason": "Administrative decision"
}
```

---

## Excuse Endpoints

**Required Role:** `user` (any authenticated user)

### Get User's Excuses

```
GET /api/excuses?status=pending
Authorization: Bearer {token}
```

---

### Submit Excuse

```
POST /api/excuses
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "report_date": "2025-10-21",
  "excuse_type": "sickness",
  "description": "Flu with fever",
  "affected_deeds": {
    "all": true
  }
}
```

**OR for specific deeds:**
```json
{
  "report_date": "2025-10-21",
  "excuse_type": "raining",
  "description": "Heavy rain prevented mosque attendance",
  "affected_deeds": ["uuid-fajr", "uuid-duha"]
}
```

---

### Get Excuse Details

```
GET /api/excuses/:id
Authorization: Bearer {token}
```

---

### Toggle Excuse Mode

```
PUT /api/users/excuse-mode
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "excuse_mode": true
}
```

---

## Excuse Management Endpoints (Supervisor/Admin)

**Required Role:** `supervisor` or `admin`

### List All Excuses

```
GET /api/admin/excuses?user_id=uuid&status=pending
Authorization: Bearer {supervisor_token}
```

---

### List Pending Excuses

```
GET /api/admin/excuses/pending
Authorization: Bearer {supervisor_token}
```

---

### Approve Excuse

```
POST /api/admin/excuses/:id/approve
Authorization: Bearer {supervisor_token}
```

**Automatically waives associated penalties if already applied**

---

### Reject Excuse

```
POST /api/admin/excuses/:id/reject
Authorization: Bearer {supervisor_token}
```

**Request Body:**
```json
{
  "reason": "Insufficient justification"
}
```

---

## Notification Endpoints

**Required Role:** `user` (any authenticated user)

### Get User's Notifications

```
GET /api/notifications?is_read=false&page=1&limit=20
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "title": "Reminder: Submit Today's Deeds",
        "body": "You have until 12 PM tomorrow...",
        "notification_type": "deadline",
        "is_read": false,
        "sent_at": "2025-10-21T21:00:00Z"
      }
    ],
    "unread_count": 5
  }
}
```

---

### Mark as Read

```
PUT /api/notifications/:id/read
Authorization: Bearer {token}
```

---

### Mark All as Read

```
PUT /api/notifications/read-all
Authorization: Bearer {token}
```

---

### Delete Notification

```
DELETE /api/notifications/:id
Authorization: Bearer {token}
```

---

### Update Notification Preferences

```
POST /api/notifications/settings
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "push_enabled": true,
  "email_enabled": false,
  "deadline_reminders": true,
  "payment_notifications": true,
  "penalty_notifications": true
}
```

---

## Notification Management Endpoints (Admin/Supervisor)

**Required Role:** `admin` or `supervisor`

### List Templates

```
GET /api/admin/notification-templates
Authorization: Bearer {admin_token}
```

---

### Update Template

```
PUT /api/admin/notification-templates/:id
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "body": "Updated body with {placeholders}"
}
```

---

### List Schedules

```
GET /api/admin/notification-schedules
Authorization: Bearer {admin_token}
```

---

### Create Schedule

```
POST /api/admin/notification-schedules
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "notification_template_id": "uuid",
  "scheduled_time": "21:00:00",
  "frequency": "daily",
  "conditions": {
    "has_pending_reports": true
  }
}
```

---

### Update Schedule

```
PUT /api/admin/notification-schedules/:id
Authorization: Bearer {admin_token}
```

---

### Send Manual Notification

```
POST /api/admin/notifications/send
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "user_ids": ["uuid1", "uuid2"],
  "title": "Important Announcement",
  "body": "System maintenance scheduled...",
  "notification_type": "info"
}
```

---

## Settings Endpoints (Admin)

**Required Role:** `admin`

### Get All Settings

```
GET /api/admin/settings
Authorization: Bearer {admin_token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "settings": [
      {
        "setting_key": "penalty_per_deed",
        "setting_value": "5000",
        "description": "Penalty amount per full deed missed",
        "data_type": "number"
      }
    ]
  }
}
```

---

### Update Setting

```
PUT /api/admin/settings/:key
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "setting_value": "6000",
  "reason": "Inflation adjustment"
}
```

---

### List Payment Methods

```
GET /api/admin/payment-methods
Authorization: Bearer {admin_token}
```

---

### Add Payment Method

```
POST /api/admin/payment-methods
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "method_name": "evc_plus",
  "display_name": "EVC Plus",
  "sort_order": 3
}
```

---

### Update Payment Method

```
PUT /api/admin/payment-methods/:id
Authorization: Bearer {admin_token}
```

---

### Delete Payment Method

```
DELETE /api/admin/payment-methods/:id
Authorization: Bearer {admin_token}
```

---

## Rest Days Endpoints

### Get Upcoming Rest Days (All Users)

```
GET /api/rest-days/upcoming
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "rest_days": [
      {
        "id": "uuid",
        "rest_date": "2025-03-29",
        "description": "Eid al-Fitr",
        "is_recurring": true
      }
    ]
  }
}
```

---

### List Rest Days (Admin)

```
GET /api/admin/rest-days
Authorization: Bearer {admin_token}
```

---

### Add Rest Day (Admin)

```
POST /api/admin/rest-days
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "rest_date": "2025-03-29",
  "description": "Eid al-Fitr",
  "is_recurring": true
}
```

---

### Update Rest Day (Admin)

```
PUT /api/admin/rest-days/:id
Authorization: Bearer {admin_token}
```

---

### Delete Rest Day (Admin)

```
DELETE /api/admin/rest-days/:id
Authorization: Bearer {admin_token}
```

---

## Leaderboard Endpoints

**Required Role:** `user` (any authenticated user)

### Get Leaderboard

```
GET /api/leaderboard?period=weekly&page=1&limit=50
Authorization: Bearer {token}
```

**Query Parameters:**
- `period` (string: daily, weekly, monthly, all_time)
- `page` (integer, default: 1)
- `limit` (integer, default: 50, max: 100)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "leaderboard": [
      {
        "rank": 1,
        "user_id": "uuid",
        "user_name": "Ahmed Hassan",
        "total_deeds": 70.0,
        "average_deeds": 10.0,
        "special_tags": ["fajr_champion", "perfect_week"]
      }
    ],
    "period_info": {
      "period_type": "weekly",
      "period_start": "2025-10-15",
      "period_end": "2025-10-21",
      "calculated_at": "2025-10-22T02:00:00Z"
    }
  }
}
```

---

### Get My Rank

```
GET /api/leaderboard/my-rank?period=weekly
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "rank": 15,
    "total_deeds": 65.5,
    "average_deeds": 9.4,
    "special_tags": ["fajr_champion"],
    "period_type": "weekly"
  }
}
```

---

## Leaderboard Management Endpoints (Supervisor/Admin)

**Required Role:** `supervisor` or `admin`

### Trigger Leaderboard Calculation

```
POST /api/admin/leaderboard/calculate
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "period_type": "weekly"
}
```

---

### Award Tag to User

```
POST /api/admin/tags/award
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "user_id": "uuid",
  "tag_id": "uuid",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

---

### Remove Tag from User

```
DELETE /api/admin/tags/remove
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "user_id": "uuid",
  "tag_id": "uuid",
  "reason": "Criteria no longer met"
}
```

---

## Analytics Endpoints (Admin/Supervisor)

**Required Role:** `admin` or `supervisor`

### Dashboard Overview Stats

```
GET /api/admin/analytics/overview
Authorization: Bearer {admin_token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": {
      "total": 150,
      "active": 120,
      "suspended": 5,
      "pending": 25
    },
    "reports": {
      "submitted_today": 85,
      "pending_today": 35,
      "compliance_rate": 70.8
    },
    "financial": {
      "total_penalties_outstanding": 2500000,
      "payments_pending_review": 15,
      "total_amount_pending": 450000
    },
    "engagement": {
      "average_daily_deeds": 8.7,
      "fajr_completion_rate": 82.5,
      "top_performer": "Ahmed Hassan"
    }
  }
}
```

---

### User Metrics

```
GET /api/admin/analytics/users?start_date=2025-10-01&end_date=2025-10-31
Authorization: Bearer {admin_token}
```

---

### Deed Metrics

```
GET /api/admin/analytics/deeds?start_date=2025-10-01&end_date=2025-10-31
Authorization: Bearer {admin_token}
```

---

### Financial Metrics

```
GET /api/admin/analytics/financial?start_date=2025-10-01&end_date=2025-10-31
Authorization: Bearer {admin_token}
```

---

### Engagement Metrics

```
GET /api/admin/analytics/engagement?start_date=2025-10-01&end_date=2025-10-31
Authorization: Bearer {admin_token}
```

---

### Export Analytics Report

```
POST /api/admin/analytics/export
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "start_date": "2025-10-01",
  "end_date": "2025-10-31",
  "format": "pdf",
  "sections": ["users", "deeds", "financial", "engagement"]
}
```

---

## Audit Log Endpoints (Admin)

**Required Role:** `admin`

### List Audit Logs

```
GET /api/admin/audit-logs?action_type=penalty_adjusted&page=1&limit=50
Authorization: Bearer {admin_token}
```

**Query Parameters:**
- `user_id` (UUID)
- `performed_by` (UUID)
- `action_type` (string)
- `entity_type` (string)
- `start_date` (date)
- `end_date` (date)

---

### Get Logs for Specific User

```
GET /api/admin/audit-logs/user/:userId
Authorization: Bearer {admin_token}
```

---

## Content Management Endpoints

### Get Content (All Users)

```
GET /api/content/:key
```

**Example:** `GET /api/content/rules_and_policies`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": {
      "title": "Rules & Policies",
      "content": "<h1>Welcome to Sabiquun App</h1>...",
      "content_type": "html",
      "version": 2,
      "updated_at": "2025-10-15T10:00:00Z"
    }
  }
}
```

---

### Update Content (Admin)

```
PUT /api/admin/content/:key
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "content": "<h1>Updated content...</h1>",
  "content_type": "html"
}
```

---

### List Announcements (Admin)

```
GET /api/admin/announcements
Authorization: Bearer {admin_token}
```

---

### Create Announcement (Admin)

```
POST /api/admin/announcements
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "title": "System Maintenance",
  "message": "The app will be under maintenance...",
  "announcement_type": "warning",
  "priority": 5,
  "is_dismissible": true,
  "start_date": "2025-10-25T00:00:00Z",
  "end_date": "2025-10-26T00:00:00Z",
  "target_roles": ["user", "supervisor", "cashier", "admin"]
}
```

---

### Update Announcement (Admin)

```
PUT /api/admin/announcements/:id
Authorization: Bearer {admin_token}
```

---

### Delete Announcement (Admin)

```
DELETE /api/admin/announcements/:id
Authorization: Bearer {admin_token}
```

---

## System Endpoints

### Get App Version Info

```
GET /api/system/version
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "current_version": "1.2.0",
    "minimum_version": "1.0.0",
    "latest_version": "1.2.0",
    "release_notes": "Bug fixes and performance improvements"
  }
}
```

---

### Check if Update Required

```
GET /api/system/force-update?app_version=1.0.0
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "update_required": true,
    "minimum_version": "1.1.0",
    "message": "Please update to continue using the app"
  }
}
```

---

### Health Check

```
GET /api/system/health
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "database": "connected",
    "timestamp": "2025-10-22T10:00:00Z"
  }
}
```

---

## Cron Jobs & Scheduled Tasks

### Daily Tasks

| Time | Task | Description |
|------|------|-------------|
| 12:00 PM | Penalty Calculation | Check users who didn't submit yesterday's report and apply penalties |
| 12:01 AM | Membership Status Update | Calculate and upgrade membership tiers based on account age |
| 12:30 PM | Draft Cleanup | Delete expired draft reports older than grace period |
| 1:00 AM | Statistics Recalculation | Recalculate user_statistics for all users |
| 2:00 AM | Leaderboard Update | Calculate daily, weekly (Mon), monthly (1st) leaderboards |
| 2:30 AM | Special Tags Assignment | Check and award/remove achievement tags (Fajr Champion, etc.) |
| 3:00 AM | Session Cleanup | Delete expired sessions, password tokens, old notifications |

### Scheduled Notifications

| Time | Notification | Target |
|------|--------------|--------|
| 9:00 PM | Deadline Reminder | Users who haven't submitted today's report |
| 11:00 AM | Grace Period Ending | Users with yesterday's pending reports |
| Sunday 10:00 AM | Payment Reminder | Users with high penalty balances |
| Day before 6:00 PM | Rest Day Announcement | All users (upcoming rest day) |

### Weekly Tasks

| Day/Time | Task | Description |
|----------|------|-------------|
| Sunday 10:00 AM | Payment Reminder | Send to users with high penalty balances |
| Monday 8:00 AM | Weekly Report Summary | Send performance summary to each user |
| Sunday 4:00 AM | Database Backup | Full database backup to cloud storage |

### Monthly Tasks

| Date/Time | Task | Description |
|-----------|------|-------------|
| 1st 5:00 AM | Monthly Analytics Report | Generate and email comprehensive report to admins |
| 1st 6:00 AM | Archive Old Data | Archive audit logs (>1yr), notifications (>90d) |

---

## Error Codes

### Authentication Errors

| Code | Message |
|------|---------|
| `INVALID_CREDENTIALS` | Invalid email or password |
| `ACCOUNT_PENDING` | Account awaiting admin approval |
| `ACCOUNT_SUSPENDED` | Account has been suspended |
| `ACCOUNT_DEACTIVATED` | Account deactivated due to penalty balance |
| `TOKEN_EXPIRED` | Authentication token has expired |
| `TOKEN_INVALID` | Invalid authentication token |
| `INSUFFICIENT_PERMISSIONS` | User role lacks required permissions |

### Validation Errors

| Code | Message |
|------|---------|
| `VALIDATION_ERROR` | Input validation failed |
| `REQUIRED_FIELD_MISSING` | Required field is missing |
| `INVALID_DATE_FORMAT` | Date must be in YYYY-MM-DD format |
| `INVALID_EMAIL` | Invalid email format |
| `PASSWORD_TOO_WEAK` | Password does not meet strength requirements |
| `DUPLICATE_ENTRY` | Resource already exists |

### Business Logic Errors

| Code | Message |
|------|---------|
| `REPORT_ALREADY_SUBMITTED` | Report for this date already submitted |
| `GRACE_PERIOD_EXPIRED` | Cannot modify report after grace period |
| `DRAFT_NOT_FOUND` | Draft report not found |
| `CANNOT_EDIT_SUBMITTED_REPORT` | Cannot edit submitted reports |
| `SYSTEM_TEMPLATE_PROTECTED` | Cannot delete system default templates |
| `PENALTY_ALREADY_PAID` | Cannot modify paid penalty |
| `PAYMENT_ALREADY_PROCESSED` | Payment has already been processed |
| `INSUFFICIENT_BALANCE` | Payment amount exceeds penalty balance |
| `EXCUSE_DEADLINE_PASSED` | Excuse submission deadline passed |

### Resource Errors

| Code | Message |
|------|---------|
| `USER_NOT_FOUND` | User not found |
| `REPORT_NOT_FOUND` | Report not found |
| `PENALTY_NOT_FOUND` | Penalty not found |
| `PAYMENT_NOT_FOUND` | Payment not found |
| `EXCUSE_NOT_FOUND` | Excuse not found |
| `TEMPLATE_NOT_FOUND` | Deed template not found |

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

| Endpoint Category | Limit | Window |
|------------------|-------|--------|
| Authentication | 5 requests | 15 minutes |
| Read Operations | 100 requests | 1 minute |
| Write Operations | 30 requests | 1 minute |
| Admin Operations | 60 requests | 1 minute |
| File Exports | 5 requests | 5 minutes |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1634567890
```

**Rate Limit Exceeded Response (429):**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "retry_after": 30
  }
}
```

---

## WebSocket Events (Real-time Updates)

For real-time notifications and updates, connect to:

```
wss://api.sabiquun.app/ws?token={jwt_token}
```

**Event Types:**
- `notification:new` - New notification received
- `penalty:applied` - Penalty applied to account
- `payment:approved` - Payment approved by admin
- `report:deadline` - Report deadline approaching
- `account:deactivated` - Account deactivated
- `leaderboard:updated` - Leaderboard rankings updated

**Event Format:**
```json
{
  "event": "notification:new",
  "data": {
    "notification_id": "uuid",
    "title": "Payment Approved",
    "body": "Your payment of 30,000 has been approved"
  },
  "timestamp": "2025-10-22T10:00:00Z"
}
```

---

## Navigation

- [Back to Business Logic](/docs/database/02-business-logic.md)
- [Back to Database Schema](/docs/database/01-schema.md)
- [Documentation Index](/docs/README.md)
