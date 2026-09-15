import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class DripPaywallScreen extends StatelessWidget {
  const DripPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaywallView(
        onPurchaseCompleted: (customerInfo, storeTransaction) {
          Navigator.of(context).pop(true);
        },
        onRestoreCompleted: (customerInfo) {
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}
