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
import 'widgets/legal_notice.dart';

/// "Sign in to your account" screen.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Map<String, String> _serverErrors = const {};
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      final user = await ref
          .read(authControllerProvider.notifier)
          .signIn(email: _email.text, password: _password.text);
      if (!mounted) return;
      AppSnackbar.success(context, 'Welcome back, ${user.firstName}!');
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
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sign in to your account', style: AppTextStyles.heading),
              const SizedBox(height: 12),
              InlineLinkText(
                segments: [
                  const TextSegment(
                    'Log in to Myafrimall to enjoy seamless shipping to over '
                    '300 countries right from Nigeria. Don\'t have an account '
                    'yet? ',
                  ),
                  TextSegment('Sign Up',
                      onTap: () => context.go(Routes.signUp)),
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 24),
              PasswordField(
                controller: _password,
                validator: (v) => Validators.required(v, 'Password'),
                serverError: _serverErrors['password'],
                onChanged: (_) => _clearServerError('password'),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              InlineLinkText(
                segments: [
                  TextSegment(
                    'Forgot Password?',
                    onTap: () => AppSnackbar.info(
                      context,
                      'Password reset will be available soon.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Login',
                loading: _submitting,
                onPressed: _submit,
                expand: context.isMobile,
              ),
              const SizedBox(height: 24),
              const LegalNotice(actionLabel: 'login'),
            ],
          ),
        ),
      ),
    );
  }
}
