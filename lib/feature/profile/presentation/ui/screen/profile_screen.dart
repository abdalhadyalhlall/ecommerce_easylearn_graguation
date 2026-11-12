import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_state.dart';
import 'package:clean_arch_session/feature/profile/presentation/ui/screen/edit_profile_screen.dart';
import 'package:clean_arch_session/feature/profile/presentation/ui/widget/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenFavorites;
  final VoidCallback onOpenOrders;

  const ProfileScreen({
    super.key,
    required this.onOpenFavorites,
    required this.onOpenOrders,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.loading && state.profile == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final profile = state.profile;
        if (profile == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    color: AppColors.muted,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.error ?? 'Unable to load your profile.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: context.read<ProfileCubit>().loadProfile,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<ProfileCubit>().loadProfile,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (state.error != null || state.message != null) ...[
                ProfileFeedback(
                  text: state.error ?? state.message!,
                  isError: state.error != null,
                ),
                const SizedBox(height: 10),
              ],
              _ProfileSummary(
                name: profile.name,
                email: profile.email,
                phone: profile.phone,
                imageUrl: profile.pictureUrl,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProfileMenuTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      onTap: () => _openEditor(context),
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.location_on_outlined,
                      title: 'Delivery Address',
                      onTap: () => _openEditor(context),
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'My Orders',
                      onTap: onOpenOrders,
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorites',
                      onTap: onOpenFavorites,
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () => _openEditor(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 45,
                child: TextButton.icon(
                  onPressed: () => context.read<AuthCubit>().logout(),
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: AppColors.error.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _separator() => const Divider(
    height: 1,
    indent: 46,
    endIndent: 14,
    color: AppColors.border,
  );

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: const EditProfileScreen(),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String? imageUrl;

  const _ProfileSummary({
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileAvatar(imageUrl: imageUrl, name: name, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
