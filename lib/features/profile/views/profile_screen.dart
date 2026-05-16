import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/error/failure_ui_extension.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/Auth/views/LoginView.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:medical_rep/features/profile/domain/usecases/update_profile_photo_usecase.dart';
import 'package:medical_rep/features/profile/views/profile_photo_picker.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';
import 'package:medical_rep/features/profile/viewmodels/profile_cubit.dart';
import 'package:medical_rep/features/profile/viewmodels/profile_state.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_header.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_info_card.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_menu_section.dart';
import 'package:medical_rep/features/profile/views/edit_profile_email_screen.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_summary_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.showBackButton = true,
    this.onSignOut,
    this.getProfileUseCase,
  });

  /// Optional injection for tests / future DI container.
  final GetProfileUseCase? getProfileUseCase;

  final bool showBackButton;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final repository = getIt.isRegistered<ProfileRepository>()
        ? getIt<ProfileRepository>()
        : ProfileRepositoryImpl();
    final getProfile = getProfileUseCase ?? GetProfileUseCase(repository);
    final updatePhoto = getIt.isRegistered<UpdateProfilePhotoUseCase>()
        ? getIt<UpdateProfilePhotoUseCase>()
        : UpdateProfilePhotoUseCase(repository);
    return BlocProvider(
      create: (_) => ProfileCubit(getProfile, updatePhoto)..load(),
      child: _ProfileView(
        showBackButton: showBackButton,
        onSignOut: onSignOut,
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.showBackButton,
    this.onSignOut,
  });

  final bool showBackButton;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) => curr is ProfileError && prev != curr,
      listener: (context, state) {
        if (state case ProfileError(:final failure)) {
          failure.showFailureDialog(
            context,
            onRetry: () => context.read<ProfileCubit>().load(),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
        ProfileLoading() => Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: const Center(child: CircularProgressIndicator()),
        ),
        ProfileError(:final failure) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
        failure.message,
        textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton(
        onPressed: () => context.read<ProfileCubit>().load(),
        child: const Text('Retry'),
        ),
        ],
        ),
        ),
        ),
        ),
        ProfileLoaded(:final user) => _ProfileScrollBody(
        user: user,
        showBackButton: showBackButton,
        onSignOut: onSignOut,
        profileCubit: context.read<ProfileCubit>(),
        isUploadingPhoto: false,
        ),
        ProfilePhotoUploading(:final user) => _ProfileScrollBody(
        user: user,
        showBackButton: showBackButton,
        onSignOut: onSignOut,
        profileCubit: context.read<ProfileCubit>(),
        isUploadingPhoto: true,
        ),
      };
      },
    );
  }
}


class _ProfileScrollBody extends StatelessWidget {
  const _ProfileScrollBody({
    required this.user,
    required this.showBackButton,
    required this.profileCubit,
    required this.isUploadingPhoto,
    this.onSignOut,
  });

  final ProfileUser user;
  final bool showBackButton;
  final ProfileCubit profileCubit;
  final bool isUploadingPhoto;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(
              showBack: showBackButton,
              title: 'Profile',
            ),
            ProfileSummaryCard(
              user: user,
              isUploadingPhoto: isUploadingPhoto,
              onEditPhoto: isUploadingPhoto ? null : () => _pickAndUploadPhoto(context),
            ),
            const SizedBox(height: 8),
            ProfileInfoCard(user: user),
            const SizedBox(height: 24),
            ProfileMenuSection(
              title: 'Account',
              items: [
                ProfileMenuItem(
                  icon: Icons.email_outlined,
                  title: 'Edit profile',
                  subtitle: 'Update email address',
                  onTap: () => _openEditEmail(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  // التعديل هنا: نداء دالة تسجيل الخروج
                  onPressed: () => _handleSignOut(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    side: BorderSide(color: AppColors.errorColor.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Log out',
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),



            const SizedBox(height: 8),
            Center(
              child: Text(
                'MedRep Field Intelligence',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.grayColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final file = await pickProfilePhoto(context);
    if (file == null || !context.mounted) return;

    final failure = await profileCubit.uploadPhoto(file);
    if (!context.mounted) return;

    if (failure != null) {
      await failure.showFailureDialog(context);
      return;
    }

    AppSnackBar.showSuccess(
      context: context,
      title: 'Photo updated',
      message: 'Your profile photo was saved.',
    );
  }

  Future<void> _openEditEmail(BuildContext context) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditProfileEmailScreen(currentEmail: user.email),
      ),
    );
    if (!context.mounted) return;
    if (updated == true) {
      await profileCubit.load();
    }
  }
}

Future<void> _handleSignOut(BuildContext context) async {
  try {
    await Supabase.instance.client.auth.signOut();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing out: $e')),
    );
  }
}



