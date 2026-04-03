import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_header.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_info_card.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_menu_section.dart';
import 'package:medical_rep/features/profile/views/widgets/profile_summary_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.user,
    this.showBackButton = true,
    this.onSignOut,
  });

  final ProfileUser? user;
  final bool showBackButton;
  final VoidCallback? onSignOut;

  static ProfileUser get _defaultUser => const ProfileUser(
        fullName: 'Ahmed Elsayed',
        email: 'ahmed.elsayed@pharma',
        repId: 'MR-2024-0042',
        roleTitle: 'Senior Medical Representative',
        regionLabel: 'Region 4',
        phone: '+20 100 000 0000',
        territory: 'Alexandria & North Coast',
      );

  @override
  Widget build(BuildContext context) {
    final data = user ?? _defaultUser;

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
              user: data,
              onEditPhoto: () {},
            ),
            const SizedBox(height: 8),
            ProfileInfoCard(user: data),
            const SizedBox(height: 24),
            ProfileMenuSection(
              title: 'Account',
              items: [
                ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit profile',
                  subtitle: 'Name, phone, territory',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Security',
                  subtitle: 'Password & devices',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            ProfileMenuSection(
              title: 'Support',
              items: [
                ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & support',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.policy_outlined,
                  title: 'Privacy',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onSignOut ?? () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    side: BorderSide(color: AppColors.errorColor.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Sign out',
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
}
