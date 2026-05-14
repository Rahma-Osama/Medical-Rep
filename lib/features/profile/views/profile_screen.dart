// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hive/hive.dart';
// import 'package:medical_rep/core/styles/app_color.dart';
// import 'package:medical_rep/core/styles/app_text_style.dart';
// import 'package:medical_rep/features/Auth/views/LoginView.dart';
// import 'package:medical_rep/features/profile/data/repositories/profile_repository_impl.dart';
// import 'package:medical_rep/features/profile/domain/usecases/get_profile_usecase.dart';
// import 'package:medical_rep/features/profile/models/profile_user.dart';
// import 'package:medical_rep/features/profile/viewmodels/profile_cubit.dart';
// import 'package:medical_rep/features/profile/viewmodels/profile_state.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_header.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_info_card.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_menu_section.dart';
// import 'package:medical_rep/features/profile/views/widgets/profile_summary_card.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key,showBackButton}) : super(key: key);
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
//        Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 20),
//   child: SizedBox(
//     width: double.infinity,
//     height: 52,
//     child: OutlinedButton(
//       // التعديل هنا: نداء دالة تسجيل الخروج
//       onPressed: () => _handleSignOut(context),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.errorColor,
//         side: BorderSide(color: AppColors.errorColor.withOpacity(0.6)),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//       child: Text(
//         'Sign out',
//         style: AppTextStyle.body.copyWith(
//           color: AppColors.errorColor,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   ),
// ),
//
//
//
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
// Future<void> _handleSignOut(BuildContext context) async {
//   try {
//     // 1. تسجيل الخروج من سوبابيز
//     await Supabase.instance.client.auth.signOut();
//
//     // 2. التوجيه لصفحة اللوج إن ومسح كل الصفحات السابقة
//     if (context.mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//         (route) => false, // ده بيمسح كل الـ history بتاع الصفحات
//       );
//     }
//   } catch (e) {
//     // إظهار رسالة خطأ لو حصل مشكلة
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error signing out: $e')),
//     );
//   }
// }
///To Be Removed
import 'package:flutter/material.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key, showBackButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


