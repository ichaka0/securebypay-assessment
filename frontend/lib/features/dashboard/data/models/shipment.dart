import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum ShipmentStatus {
  pendingPayment('pending_payment', 'Pending', AppColors.textSecondary,
      AppColors.surfaceMuted),
  inTransit('in_transit', 'In transit', AppColors.warning, AppColors.warningBg),
  delayed('delayed', 'Delayed', AppColors.info, AppColors.infoBg),
  delivered('delivered', 'Delivered', AppColors.success, AppColors.successBg);

  const ShipmentStatus(this.apiValue, this.label, this.color, this.background);

  final String apiValue;
  final String label;
  final Color color;
  final Color background;

  static ShipmentStatus fromApi(String value) => values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => ShipmentStatus.pendingPayment,
      );
}

class Shipment {
  const Shipment({
    required this.id,
    required this.trackingId,
    required this.sender,
    required this.receiver,
    required this.pickupFrom,
    required this.pickupCountry,
    required this.deliveryTo,
    required this.deliveryCountry,
    required this.amount,
    required this.status,
    required this.isExport,
    required this.processingHours,
    required this.isPaid,
    required this.shippedAt,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        id: json['id'] as String,
        trackingId: json['trackingId'] as String,
        sender: json['sender'] as String,
        receiver: json['receiver'] as String,
        pickupFrom: json['pickupFrom'] as String,
        pickupCountry: json['pickupCountry'] as String,
        deliveryTo: json['deliveryTo'] as String,
        deliveryCountry: json['deliveryCountry'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: ShipmentStatus.fromApi(json['status'] as String),
        isExport: json['type'] == 'export',
        processingHours: (json['processingHours'] as num).toInt(),
        isPaid: json['isPaid'] as bool,
        shippedAt: DateTime.parse(json['shippedAt'] as String).toLocal(),
      );

  final String id;
  final String trackingId;
  final String sender;
  final String receiver;
  final String pickupFrom;
  final String pickupCountry;
  final String deliveryTo;
  final String deliveryCountry;
  final double amount;
  final ShipmentStatus status;
  final bool isExport;
  final int processingHours;
  final bool isPaid;
  final DateTime shippedAt;

  Shipment copyWith({bool? isPaid}) => Shipment(
        id: id,
        trackingId: trackingId,
        sender: sender,
        receiver: receiver,
        pickupFrom: pickupFrom,
        pickupCountry: pickupCountry,
        deliveryTo: deliveryTo,
        deliveryCountry: deliveryCountry,
        amount: amount,
        status: status,
        isExport: isExport,
        processingHours: processingHours,
        isPaid: isPaid ?? this.isPaid,
        shippedAt: shippedAt,
      );
}

class ShipmentPage {
  const ShipmentPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory ShipmentPage.fromJson(Map<String, dynamic> json) => ShipmentPage(
        items: (json['items'] as List)
            .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: (json['page'] as num).toInt(),
        limit: (json['limit'] as num).toInt(),
        total: (json['total'] as num).toInt(),
      );

  final List<Shipment> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => page * limit < total;
}
