import 'package:clean_arch_session/core/routes/routes.dart';
import 'package:clean_arch_session/core/widgets/app_button.dart';
import 'package:clean_arch_session/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _orange = Color(0xFFFF6A00);
const _ink = Color(0xFF20232B);
const _muted = Color(0xFF85858A);
const _cream = Color(0xFFFFF9F4);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _openOtp(String email) {
    Navigator.pushNamed(context, Routes.otp, arguments: email);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _cream,
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthOtpRequired) {
                _openOtp(state.email);
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: _ShopMark(size: 88)),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Sign in to continue shopping',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted, fontSize: 13),
                          ),
                          const SizedBox(height: 28),
                          _AuthField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty ||
                                  !email.contains('@') ||
                                  !email.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _AuthField(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 19,
                                color: _muted,
                              ),
                            ),
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'Enter your password'
                                : null,
                            onSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 23),
                          AppButton(
                            text: 'Login',
                            isLoading: state is AuthLoading,
                            backgroundColor: _orange,
                            onPressed: _login,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    Routes.register,
                                  ),
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _muted,
                                ),
                                children: [
                                  TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: TextStyle(
                                      color: _orange,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShopMark extends StatelessWidget {
  final double size;

  const _ShopMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 5)),
        ],
      ),
      child: const Icon(Icons.shopping_bag_rounded, color: _orange, size: 42),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _AuthField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        labelStyle: const TextStyle(fontSize: 12, color: _muted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFECE7E3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFECE7E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange),
        ),
      ),
    );
  }
}
