import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/country_flag.dart';
import '../../data/models/shipment.dart';
import 'common.dart';

/// Expandable shipment summary from the "Recent shipment" list.
///
/// Wide cards lay fields out in columns like the design; narrow cards
/// (< 560px) switch to a two-column grid so nothing is truncated.
class ShipmentCard extends StatefulWidget {
  const ShipmentCard({
    super.key,
    required this.shipment,
    required this.onPay,
    this.initiallyExpanded = true,
  });

  final Shipment shipment;

  /// Pays for the shipment; the card shows a spinner until it completes.
  final Future<void> Function() onPay;
  final bool initiallyExpanded;

  @override
  State<ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<ShipmentCard> {
  late bool _expanded = widget.initiallyExpanded;
  bool _paying = false;

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      await widget.onPay();
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shipment;
    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _headerRow(s, narrow),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _details(s, narrow),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerRow(Shipment s, bool narrow) {
    final tracking = _Field(
      label: 'Tracking ID',
      child: Text(
        s.trackingId,
        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
      ),
    );
    final sender = _Field(label: 'Sender', value: s.sender);
    final receiver = _Field(label: 'Receiver', value: s.receiver);
    final toggle = IconButton(
      tooltip: _expanded ? 'Collapse' : 'Expand',
      visualDensity: VisualDensity.compact,
      icon: AnimatedRotation(
        turns: _expanded ? 0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
      ),
      onPressed: () => setState(() => _expanded = !_expanded),
    );

    if (narrow) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Grid(children: [tracking, sender, receiver]),
          ),
          toggle,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 24, child: tracking),
        Expanded(flex: 18, child: sender),
        Expanded(flex: 58, child: receiver),
        toggle,
      ],
    );
  }

  Widget _details(Shipment s, bool narrow) {
    final pickup = _Field(
      label: 'Pick Up From',
      child: _Place(name: s.pickupFrom, countryCode: s.pickupCountry),
    );
    final delivery = _Field(
      label: 'Delivery To',
      child: _Place(name: s.deliveryTo, countryCode: s.deliveryCountry),
    );
    final amount =
        _Field(label: 'Amount', value: Formatters.currencyWhole(s.amount));
    final status = _Field(
      label: 'Status',
      alignEnd: !narrow,
      child: StatusChip(
        label: s.status.label,
        color: s.status.color,
        background: s.status.background,
      ),
    );
    final processing = _Field(
      label: 'Processing time',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            Formatters.hours(s.processingHours),
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => showShipmentDetails(context, s),
          child: const Text('View More'),
        ),
        if (s.isPaid)
          ElevatedButton(
            onPressed: null,
            style: _smallFilled(AppColors.surfaceMuted, AppColors.textMuted),
            child: const Text('Paid'),
          )
        else
          ElevatedButton(
            onPressed: _paying ? null : _pay,
            style: _smallFilled(AppColors.navy, AppColors.white),
            child: _paying
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Pay Now'),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          const SizedBox(height: 12),
          if (narrow)
            _Grid(children: [pickup, delivery, amount, status])
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 32, child: pickup),
                Expanded(flex: 32, child: delivery),
                Expanded(flex: 26, child: amount),
                Expanded(flex: 10, child: status),
              ],
            ),
          const SizedBox(height: 14),
          if (narrow) ...[
            processing,
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: actions),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                processing,
                const Spacer(),
                actions,
              ],
            ),
        ],
      ),
    );
  }

  static ButtonStyle _smallFilled(Color background, Color foreground) =>
      ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background,
        disabledForegroundColor: foreground,
        minimumSize: const Size(72, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
      );
}

/// Two-column grid for narrow cards.
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final c in children) SizedBox(width: width, child: c)
          ],
        );
      },
    );
  }
}

/// Small grey label with a value underneath.
class _Field extends StatelessWidget {
  const _Field(
      {required this.label, this.value, this.child, this.alignEnd = false})
      : assert(value != null || child != null);

  final String label;
  final String? value;
  final Widget? child;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.tiny),
        const SizedBox(height: 6),
        child ??
            Text(
              value!,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
      ],
    );
  }
}

class _Place extends StatelessWidget {
  const _Place({required this.name, required this.countryCode});

  final String name;
  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CountryFlag(countryCode: countryCode),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            name,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// "View More" dialog with every field of a shipment.
Future<void> showShipmentDetails(BuildContext context, Shipment s) {
  final rows = <(String, String)>[
    ('Tracking ID', s.trackingId),
    ('Type', s.isExport ? 'Export' : 'Import'),
    ('Sender', s.sender),
    ('Receiver', s.receiver),
    ('Pick Up From', s.pickupFrom),
    ('Delivery To', s.deliveryTo),
    ('Amount', Formatters.currency(s.amount)),
    ('Payment', s.isPaid ? 'Paid' : 'Awaiting payment'),
    ('Status', s.status.label),
    ('Processing time', Formatters.hours(s.processingHours)),
    ('Booked on', DateFormat('d MMM yyyy, h:mm a').format(s.shippedAt)),
  ];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl)),
      title: Text('Shipment details', style: AppTextStyles.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, minWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 130,
                        child: Text(label, style: AppTextStyles.caption)),
                    Expanded(
                      child: Text(
                        value,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close')),
      ],
    ),
  );
}
