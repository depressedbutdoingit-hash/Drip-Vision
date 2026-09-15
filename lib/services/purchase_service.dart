import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/env.dart';
import '../models/user_profile.dart';

class PurchaseService {
  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    final config = PurchasesConfiguration(
      Platform.isIOS ? Env.revenueCatIosKey : Env.revenueCatAndroidKey,
    );
    config.appUserID = FirebaseAuth.instance.currentUser?.uid;
    await Purchases.configure(config);
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      throw Exception('Failed to fetch offerings: ${e.message}');
    }
  }

  static Future<bool> makePurchase(Package package) async {
    try {
      final info = await Purchases.purchasePackage(package);
      await _syncEntitlements(info);
      return info.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) != PurchasesErrorCode.purchaseCancelledError) {
        throw Exception('Purchase failed: ${e.message}');
      }
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      await _syncEntitlements(info);
      return info.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      throw Exception('Restore failed: ${e.message}');
    }
  }

  static Future<void> _syncEntitlements(CustomerInfo info) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final tier = info.entitlements.all['pro']?.isActive == true
        ? 'pro'
        : info.entitlements.all['starter']?.isActive == true
            ? 'starter'
            : 'free';

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'subscriptionTier': tier,
    });
  }

  static Future<UserProfile> fetchUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserProfile.fromMap(doc.data() ?? {}, uid);
  }

  static Future<void> updateTokenBalance(int newBalance) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'tokenBalance': newBalance,
    });
  }

  static Future<void> claimMonthlyFree() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'tokenBalance': 15,
      'lastFreeClaimDate': DateTime.now(),
    });
  }
}
