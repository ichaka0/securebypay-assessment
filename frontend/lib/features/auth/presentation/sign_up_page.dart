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
import '../data/models/auth_requests.dart';
import 'widgets/auth_layout.dart';
import 'widgets/inline_link_text.dart';
import 'widgets/legal_notice.dart';

/// "Create an account" screen.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  /// Backend validation messages keyed by request field name.
  Map<String, String> _serverErrors = const {};
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _phone, _password]) {
      c.dispose();
    }
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
      final user = await ref.read(authControllerProvider.notifier).signUp(
            RegisterRequest(
              firstName: _firstName.text,
              lastName: _lastName.text,
              email: _email.text,
              phoneNumber: _phone.text,
              password: _password.text,
            ),
          );
      if (!mounted) return;
      AppSnackbar.success(
        context,
        'Account created successfully. Welcome, ${user.firstName}!',
      );
      // The router redirects to the dashboard once the session is set.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrors = {
          ...e.fieldErrors,
          if (e.statusCode == 409) 'email': e.message,
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
    final stackNames = context.isMobile;
    final firstName = AppTextField(
      label: 'First name',
      hint: 'John',
      controller: _firstName,
      validator: (v) => Validators.required(v, 'First name'),
      serverError: _serverErrors['firstName'],
      onChanged: (_) => _clearServerError('firstName'),
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.givenName],
    );
    final lastName = AppTextField(
      label: 'Last name',
      hint: 'Doe',
      controller: _lastName,
      validator: (v) => Validators.required(v, 'Last name'),
      serverError: _serverErrors['lastName'],
      onChanged: (_) => _clearServerError('lastName'),
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.familyName],
    );

    return AuthLayout(
      heroTitle: 'Seamlessly Delivering to Over 300 Countries from Nigeria!',
      heroSubtitle:
          'Access global markets with our quick shipping from Nigeria! Fast '
          'delivery and easy customs to 300+ countries.',
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create an account', style: AppTextStyles.heading),
              const SizedBox(height: 12),
              InlineLinkText(
                segments: [
                  const TextSegment(
                    'Sign up for Myafrimall and gain unlimited access to '
                    'shipping to over 300 countries from Nigeria. Do you '
                    'already have an account? ',
                  ),
                  TextSegment('Login', onTap: () => context.go(Routes.signIn)),
                ],
              ),
              const SizedBox(height: 32),
              if (stackNames) ...[
                firstName,
                const SizedBox(height: 24),
                lastName,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: firstName),
                    const SizedBox(width: 24),
                    Expanded(child: lastName),
                  ],
                ),
              const SizedBox(height: 24),
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
              PhoneField(
                controller: _phone,
                validator: Validators.nigerianPhone,
                serverError: _serverErrors['phoneNumber'],
                onChanged: (_) => _clearServerError('phoneNumber'),
              ),
              const SizedBox(height: 24),
              PasswordField(
                controller: _password,
                validator: Validators.newPassword,
                serverError: _serverErrors['password'],
                onChanged: (_) => _clearServerError('password'),
                onSubmitted: (_) => _submit(),
                isNewPassword: true,
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Create account',
                loading: _submitting,
                onPressed: _submit,
                expand: stackNames,
              ),
              const SizedBox(height: 24),
              const LegalNotice(actionLabel: 'create account'),
            ],
          ),
        ),
      ),
    );
  }
}
