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


class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  Map<String, String> _serverErrors = const {};
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = Map.of(_serverErrors)..remove(field));
    }
  }

  Future<void> _submit() async {
    setState(() => _serverErrors = const {});
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final reset = await ref
          .read(authControllerProvider.notifier)
          .requestPasswordReset(_email.text);
      if (!mounted) return;
      AppSnackbar.success(
        context,
        'We\'ve verified your account. Choose a new password.',
      );
      context.go('${Routes.resetPassword}?token=${reset.token}');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrors = {
          ...e.fieldErrors,
          if (e.statusCode == 404) 'email': e.message,
        };
      });
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
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Forgot your password?', style: AppTextStyles.heading),
              const SizedBox(height: 12),
              InlineLinkText(
                segments: [
                  const TextSegment(
                    'Enter the email linked to your account and we\'ll help you '
                    'set a new password. Remembered it? ',
                  ),
                  TextSegment(
                    'Back to login',
                    onTap: () => context.go(Routes.signIn),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Email',
                hint: 'user@example.com',
                controller: _email,
                validator: Validators.email,
                serverError: _serverErrors['email'],
                onChanged: (_) => _clearServerError('email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Continue',
                loading: _submitting,
                onPressed: _submit,
                expand: context.isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
