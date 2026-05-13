// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medical_rep/core/styles/app_color.dart';
// import 'package:medical_rep/core/styles/app_text_style.dart';
// import 'package:medical_rep/features/profile/models/profile_user.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_header.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_info_card.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_menu_section.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_summary_card.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({
//     super.key,
//     this.showBackButton = true,
//     this.onSignOut,
//     this.getProfileUseCase,
//   });
//
//   /// Optional injection for tests / future DI container.
//   final GetProfileUseCase? getProfileUseCase;
//
//   final bool showBackButton;
//   final VoidCallback? onSignOut;
//
//   @override
//   Widget build(BuildContext context) {
//     final useCase = getProfileUseCase ?? GetProfileUseCase(ProfileRepositoryImpl());
//     return BlocProvider(
//       create: (_) => ProfileCubit(useCase)..load(),
//       child: _ProfileView(
//         showBackButton: showBackButton,
//         onSignOut: onSignOut,
//       ),
//     );
//   }
// }
//
// class _ProfileView extends StatelessWidget {
//   const _ProfileView({
//     required this.showBackButton,
//     this.onSignOut,
//   });
//
//   final bool showBackButton;
//   final VoidCallback? onSignOut;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ProfileCubit, ProfileState>(
//       builder: (context, state) {
//         return switch (state) {
//           ProfileLoading() => Scaffold(
//               backgroundColor: AppColors.backgroundColor,
//               body: const Center(child: CircularProgressIndicator()),
//             ),
//           ProfileError(:final message) => Scaffold(
//               backgroundColor: AppColors.backgroundColor,
//               body: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(message, textAlign: TextAlign.center),
//                       const SizedBox(height: 16),
//                       FilledButton(
//                         onPressed: () => context.read<ProfileCubit>().load(),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ProfileLoaded(:final user) => _ProfileScrollBody(
//               user: user,
//               showBackButton: showBackButton,
//               onSignOut: onSignOut,
//             ),
//         };
//       },
//     );
//   }
// }
//
// class _ProfileScrollBody extends StatelessWidget {
//   const _ProfileScrollBody({
//     required this.user,
//     required this.showBackButton,
//     this.onSignOut,
//   });
//
//   final ProfileUser user;
//   final bool showBackButton;
//   final VoidCallback? onSignOut;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ProfileHeader(
//               showBack: showBackButton,
//               title: 'Profile',
//             ),
//             ProfileSummaryCard(
//               user: user,
//               onEditPhoto: () {},
//             ),
//             const SizedBox(height: 8),
//             ProfileInfoCard(user: user),
//             const SizedBox(height: 24),
//             ProfileMenuSection(
//               title: 'Account',
//               items: [
//                 ProfileMenuItem(
//                   icon: Icons.person_outline_rounded,
//                   title: 'Edit profile',
//                   subtitle: 'Name, phone, territory',
//                   onTap: () {},
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             ProfileMenuSection(
//               title: 'Support',
//               items: [
//                 ProfileMenuItem(
//                   icon: Icons.help_outline_rounded,
//                   title: 'Help & support',
//                   onTap: () {},
//                 ),
//                 ProfileMenuItem(
//                   icon: Icons.policy_outlined,
//                   title: 'Privacy',
//                   onTap: () {},
//                 ),
//               ],
//             ),
//             const SizedBox(height: 28),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: OutlinedButton(
//                   onPressed: onSignOut ?? () => Navigator.of(context).maybePop(),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.errorColor,
//                     side: BorderSide(color: AppColors.errorColor.withValues(alpha: 0.6)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: Text(
//                     'Sign out',
//                     style: AppTextStyle.body.copyWith(
//                       color: AppColors.errorColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Center(
//               child: Text(
//                 'MedRep Field Intelligence',
//                 style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                       color: AppColors.grayColor,
//                     ),
//               ),
//             ),
//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// Remove this
import 'package:flutter/material.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key,showBackButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
