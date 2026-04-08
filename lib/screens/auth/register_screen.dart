import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../widgets/auth/auth_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (success && mounted) {
        // Đăng ký thành công, quay lại màn hình trước
        Navigator.pop(context);
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? l10n.registerFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: const Color(0xFF132B45),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 6),
            AuthHeader(
              title: l10n.createAccountTitle,
              subtitle: l10n.createAccountSubtitle,
            ),
            const SizedBox(height: 24),
            AuthTextField(
              controller: _nameController,
              label: l10n.name,
              hintText: l10n.nameHint,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: l10n.email,
              hintText: l10n.emailHint,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationEmailRequired;
                }
                if (!value.contains('@')) {
                  return l10n.validationEmailInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.password,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF445D7F),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: l10n.passwordHint,
                hintStyle: TextStyle(
                  color: const Color(0xFF445D7F).withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: kAuthPrimary.withValues(alpha: 0.8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF445D7F).withValues(alpha: 0.8),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.18)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: kAuthPrimary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.red.withValues(alpha: 0.7)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.red.withValues(alpha: 0.8)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationPasswordRequired;
                }
                if (value.length < 6) {
                  return l10n.validationPasswordMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.confirmPassword,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF445D7F),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: l10n.confirmPasswordHint,
                hintStyle: TextStyle(
                  color: const Color(0xFF445D7F).withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: kAuthPrimary.withValues(alpha: 0.8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF445D7F).withValues(alpha: 0.8),
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.18)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: kAuthPrimary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.red.withValues(alpha: 0.7)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      BorderSide(color: Colors.red.withValues(alpha: 0.8)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationConfirmPasswordRequired;
                }
                if (value != _passwordController.text) {
                  return l10n.validationPasswordMismatch;
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleRegister(),
            ),
            const SizedBox(height: 22),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return AuthGradientButton(
                  label: l10n.register,
                  isLoading: authProvider.isLoading,
                  onPressed: authProvider.isLoading ? null : _handleRegister,
                );
              },
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l10n.alreadyHaveAccount} ',
                  style: TextStyle(
                    color: const Color(0xFF445D7F).withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: kAuthPrimary),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    l10n.login,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


