import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/dashboard_providers.dart';

/// Opens the "Fund Wallet" dialog.
Future<void> showFundWalletDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (_) => const _FundWalletDialog(),
    );

class _FundWalletDialog extends ConsumerStatefulWidget {
  const _FundWalletDialog();

  @override
  ConsumerState<_FundWalletDialog> createState() => _FundWalletDialogState();
}

class _FundWalletDialogState extends ConsumerState<_FundWalletDialog> {
  static const _quickAmounts = [5000, 10000, 50000];
  static const _min = 100;
  static const _max = 10000000;

  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String? _serverError;
  bool _submitting = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final amount = double.tryParse((value ?? '').replaceAll(',', ''));
    if (amount == null) return 'Enter an amount';
    if (amount < _min) {
      return 'Minimum amount is ${Formatters.currencyWhole(_min)}';
    }
    if (amount > _max) {
      return 'Maximum amount is ${Formatters.currencyWhole(_max)}';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.parse(_amount.text.replaceAll(',', ''));
    setState(() => _submitting = true);
    try {
      await fundWallet(ref, amount);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(
        context,
        'Wallet funded with ${Formatters.currency(amount)}.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.fieldErrors['amount'] ?? e.message);
      _formKey.currentState?.validate();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      title: Text('Fund Wallet', style: AppTextStyles.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, minWidth: 280),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payments are simulated in this demo; the amount is credited '
                'to your wallet immediately.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Amount (₦)',
                hint: 'e.g. 50000',
                controller: _amount,
                validator: _validate,
                serverError: _serverError,
                onChanged: (_) {
                  if (_serverError != null) setState(() => _serverError = null);
                },
                onSubmitted: (_) => _submit(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final value in _quickAmounts)
                    ActionChip(
                      label: Text(Formatters.currencyWhole(value)),
                      labelStyle: AppTextStyles.caption,
                      side: const BorderSide(color: AppColors.border),
                      backgroundColor: AppColors.white,
                      onPressed: () => setState(() {
                        _amount.text = value.toString();
                        _serverError = null;
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
            label: 'Fund Wallet', loading: _submitting, onPressed: _submit),
      ],
    );
  }
}
