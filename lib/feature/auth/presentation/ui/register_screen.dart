import 'dart:typed_data';

import 'package:clean_arch_session/core/routes/routes.dart';
import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/feature/auth/domain/entities/register_entity.dart';
import 'package:clean_arch_session/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:clean_arch_session/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _picker = ImagePicker();
  String? _pictureFileName;
  Uint8List? _pictureBytes;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _pickPicture() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pictureFileName = image.name;
        _pictureBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select picture: $error')),
      );
    }
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
      RegisterEntity(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmationController.text,
        pictureBytes: _pictureBytes,
        pictureFileName: _pictureFileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Create Account',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthOtpRequired) {
                Navigator.pushNamed(
                  context,
                  Routes.otp,
                  arguments: state.email,
                );
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: InkWell(
                              onTap: state is AuthLoading ? null : _pickPicture,
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                width: 58,
                                height: 58,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryContainer,
                                  border: Border.all(
                                    color: AppColors.primaryBorder,
                                  ),
                                ),
                                child: _pictureBytes == null
                                    ? const Icon(
                                        Icons.camera_alt_outlined,
                                        color: AppColors.primary,
                                        size: 22,
                                      )
                                    : Image.memory(
                                        _pictureBytes!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add a profile picture (optional)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RegisterField(
                            controller: _nameController,
                            label: 'Full Name *',
                            validator: (value) =>
                                (value?.trim().isEmpty ?? true)
                                ? 'Enter your full name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _RegisterField(
                            controller: _emailController,
                            label: 'Email *',
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
                          const SizedBox(height: 12),
                          _RegisterField(
                            controller: _phoneController,
                            label: 'Phone *',
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                (value?.trim().isEmpty ?? true)
                                ? 'Enter your phone number'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _RegisterField(
                            controller: _addressController,
                            label: 'Address (optional)',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _RegisterField(
                                  controller: _latitudeController,
                                  label: 'Latitude (optional)',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _RegisterField(
                                  controller: _longitudeController,
                                  label: 'Longitude (optional)',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _RegisterField(
                            controller: _passwordController,
                            label: 'Password *',
                            obscureText: _obscurePassword,
                            suffix: _visibilityButton(
                              _obscurePassword,
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            validator: (value) => (value?.length ?? 0) < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _RegisterField(
                            controller: _confirmationController,
                            label: 'Confirm Password *',
                            obscureText: _obscureConfirmation,
                            suffix: _visibilityButton(
                              _obscureConfirmation,
                              () => setState(
                                () => _obscureConfirmation =
                                    !_obscureConfirmation,
                              ),
                            ),
                            validator: (value) =>
                                value != _passwordController.text
                                ? 'Passwords do not match'
                                : null,
                            onSubmitted: (_) => _register(),
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            text: 'Create Account',
                            isLoading: state is AuthLoading,
                            backgroundColor: AppColors.primary,
                            onPressed: _register,
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                                children: [
                                  TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: AppColors.primary,
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

  Widget _visibilityButton(bool obscure, VoidCallback onPressed) {
    return IconButton(
      tooltip: obscure ? 'Show password' : 'Hide password',
      onPressed: onPressed,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 19,
        color: AppColors.muted,
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _RegisterField({
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
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
