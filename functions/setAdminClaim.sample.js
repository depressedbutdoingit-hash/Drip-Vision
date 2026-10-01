/**
 * Deploy with Firebase Functions (Admin SDK).
 * Call once for your owner UID to set custom claim admin: true.
 *
 * Example callable:
 * exports.setAdminClaim = functions.https.onCall(async (data, context) => {
 *   if (!context.auth || context.auth.token.admin !== true) {
 *     // Bootstrap: allow only a hardcoded owner email for first run, then remove.
 *     throw new functions.https.HttpsError('permission-denied', 'Not admin');
 *   }
 *   const uid = data.uid;
 *   await admin.auth().setCustomUserClaims(uid, { admin: true });
 *   return { ok: true };
 * });
 *
 * One-shot bootstrap (Node script with service account):
 *   await admin.auth().setCustomUserClaims('YOUR_UID', { admin: true });
 */
