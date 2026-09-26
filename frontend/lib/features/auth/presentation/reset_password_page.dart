import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_layout.dart';
import 'widgets/inline_link_text.dart';

/// "Set a new password" screen. The [token] comes from the reset link
/// (query parameter), so the page can be reached directly.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  Map<String, String> _serverErrors = const {};
  bool _submitting = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = Map.of(_serverErrors)..remove(field));
    }
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != _password.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _serverErrors = const {});
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
            token: widget.token,
            password: _password.text,
          );
      if (!mounted) return;
      AppSnackbar.success(
        context,
        'Password updated. Sign in with your new password.',
      );
      context.go(Routes.signIn);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _serverErrors = e.fieldErrors);
      _formKey.currentState?.validate();
      AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      heroTitle: 'Effortlessly Track Your Shipments from Nigeria!',
      heroSubtitle:
          'Monitor your shipments from Nigeria! Enjoy swift delivery and '
          'seamless customs processing',
      form: widget.token.isEmpty ? _missingToken(context) : _resetForm(context),
    );
  }

  Widget _resetForm(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set a new password', style: AppTextStyles.heading),
            const SizedBox(height: 12),
            const InlineLinkText(
              segments: [
                TextSegment(
                  'Choose a strong password you don\'t use anywhere else. It '
                  'must be at least 8 characters with a letter and a number.',
                ),
              ],
            ),
            const SizedBox(height: 32),
            PasswordField(
              label: 'New password',
              controller: _password,
              validator: Validators.newPassword,
              serverError: _serverErrors['password'],
              onChanged: (_) => _clearServerError('password'),
              textInputAction: TextInputAction.next,
              isNewPassword: true,
            ),
            const SizedBox(height: 24),
            PasswordField(
              label: 'Confirm new password',
              controller: _confirm,
              validator: _validateConfirm,
              onSubmitted: (_) => _submit(),
              isNewPassword: true,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Reset password',
              loading: _submitting,
              onPressed: _submit,
              expand: context.isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _missingToken(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Reset link needed', style: AppTextStyles.heading),
        const SizedBox(height: 12),
        InlineLinkText(
          segments: [
            const TextSegment(
              'This page needs a valid reset link. Start over to request a new '
              'one. ',
            ),
            TextSegment(
              'Forgot password',
              onTap: () => context.go(Routes.forgotPassword),
            ),
          ],
        ),
      ],
    );
  }
}
