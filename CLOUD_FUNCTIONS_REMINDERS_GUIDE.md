# Firebase Cloud Functions: Automated Hearing Reminders Guide

This document outlines the architecture, implementation, and deployment steps for adding automated 24-hour hearing reminders via Firebase Cloud Functions once the Firebase project is upgraded to the **Blaze (Pay-as-you-go)** plan.

---

## 1. Overview & Architecture

### Why Cloud Functions are Required
- Time-based triggers (e.g. *"send an alert 24 hours before tomorrow's 10:00 AM hearing"*) cannot be executed reliably from client devices when the app is closed or in background.
- A scheduled Cloud Function acts as a secure, serverless cron job that runs daily (e.g. at 8:00 AM PKT), queries upcoming hearings across all cases, and writes reminder notification documents to `users/{userId}/notifications`.

### Cost Breakdown on Blaze Plan
- **Cloud Scheduler**: 3 free jobs per month.
- **Cloud Functions Invocation**: 2,000,000 free invocations/month.
- **Firestore Reads/Writes**: 50,000 reads/day free, 20,000 writes/day free.
- **Estimated Real Cost**: **$0.00 / month** for standard production volume (< 100,000 monthly active users).

---

## 2. Step-by-Step Setup Instructions

### Step 2.1: Upgrade Firebase Plan
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select your project (`law-app` / `mashvira-law-house`).
3. Click the **Upgrade** button in the lower-left corner and choose the **Blaze (Pay-as-you-go)** plan.

### Step 2.2: Initialize Cloud Functions
From your terminal in the root directory:
```bash
npm install -g firebase-tools
firebase login
firebase init functions
```
- Select **TypeScript** (or JavaScript).
- Choose **ESLint** for code quality.
- Choose to install dependencies with **npm**.

This creates a `functions/` directory in your repository.

---

## 3. Implementation Code

Replace `functions/src/index.ts` with the following implementation:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

/**
 * Scheduled Cron Job: Runs every day at 08:00 AM Pakistan Standard Time (UTC+5).
 * Finds hearings scheduled for tomorrow and generates 24-hour reminder notifications.
 */
export const sendDailyHearingReminders = functions.pubsub
  .schedule('0 8 * * *')
  .timeZone('Asia/Karachi')
  .onRun(async (context) => {
    const now = new Date();
    
    // Tomorrow's start (00:00:00) and end (23:59:59)
    const tomorrowStart = new Date(now);
    tomorrowStart.setDate(now.getDate() + 1);
    tomorrowStart.setHours(0, 0, 0, 0);

    const tomorrowEnd = new Date(tomorrowStart);
    tomorrowEnd.setHours(23, 59, 59, 999);

    console.log(`Checking hearings between ${tomorrowStart.toISOString()} and ${tomorrowEnd.toISOString()}`);

    const casesSnapshot = await db.collection('cases').get();
    let remindersSent = 0;

    for (const caseDoc of casesSnapshot.docs) {
      const caseData = caseDoc.data();
      const caseDocId = caseDoc.id;
      const clientUserId = caseData.userId;
      const lawyerId = caseData.assignedLawyer?.lawyerId || caseData.lawyerId;
      const caseTitle = caseData.shortDescription || caseData.title || caseData.caseId || 'Your Case';
      const caseIdFormatted = caseData.caseId || caseDocId;

      // Query hearings for tomorrow
      const hearingsSnapshot = await db
        .collection('cases')
        .doc(caseDocId)
        .collection('hearings')
        .where('date', '>=', admin.firestore.Timestamp.fromDate(tomorrowStart))
        .where('date', '<=', admin.firestore.Timestamp.fromDate(tomorrowEnd))
        .get();

      for (const hearingDoc of hearingsSnapshot.docs) {
        const hearingData = hearingDoc.data();
        if (hearingData.status === 'completed') continue;

        const time = hearingData.time || '10:00 AM';
        const courtName = hearingData.courtName || 'Court';
        const courtRoom = hearingData.courtRoom ? ` (${hearingData.courtRoom})` : '';

        // 1. Send Reminder to Client
        if (clientUserId) {
          await db
            .collection('users')
            .doc(clientUserId)
            .collection('notifications')
            .add({
              type: 'hearing_reminder',
              title: 'Hearing Tomorrow',
              description: `Reminder: You have a scheduled hearing tomorrow for "${caseTitle}" (ID: ${caseIdFormatted}) at ${time} at ${courtName}${courtRoom}.`,
              caseId: caseIdFormatted,
              isRead: false,
              isNew: true,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          remindersSent++;
        }

        // 2. Send Reminder to Lawyer
        if (lawyerId) {
          await db
            .collection('users')
            .doc(lawyerId)
            .collection('notifications')
            .add({
              type: 'hearing_reminder',
              title: 'Hearing Tomorrow (Lawyer Reminder)',
              description: `Reminder: You have a hearing scheduled tomorrow for case ${caseIdFormatted} (${caseTitle}) at ${time} in ${courtName}${courtRoom}.`,
              caseId: caseIdFormatted,
              isRead: false,
              isNew: true,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          remindersSent++;
        }
      }
    }

    console.log(`Successfully dispatched ${remindersSent} hearing reminders.`);
    return null;
  });
```

---

## 4. Deployment

Deploy the scheduled function with:
```bash
firebase deploy --only functions
```

Verify in the **Firebase Console → Functions** tab that `sendDailyHearingReminders` is listed with schedule `0 8 * * * (Asia/Karachi)`.

---

## 5. Client & Mobile Handling

The mobile apps (`law_app` & `law_app_admin`) already have full in-app notification support and UI badges for `type: 'hearing_reminder'` and `type: 'hearing'`, so once deployed, notifications will appear instantly in the user's Alerts feed.
