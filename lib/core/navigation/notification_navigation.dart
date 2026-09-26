import 'package:flutter/material.dart';

import '../../features/sales/presentation/screens/sale_detail_screen.dart';

class NotificationNavigation {
  NotificationNavigation._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static Map<String, dynamic>? _pendingData;

  static void openFromData(Map<String, dynamic> data) {
    final feature = data['feature']?.toString();
    final saleId = data['sale_id']?.toString();

    if (feature != 'sale_detail' || saleId == null || saleId.isEmpty) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingData = Map<String, dynamic>.from(data);
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => SaleDetailScreen(
          saleId: saleId,
          notificationTotal: data['total']?.toString(),
        ),
      ),
    );
  }

  static void openPendingIfAny() {
    final data = _pendingData;
    if (data == null) return;
    _pendingData = null;
    openFromData(data);
  }
}
