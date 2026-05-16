// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medical_rep/core/styles/app_color.dart';
// import 'package:medical_rep/features/Auth/domain/repositories/auth_repository.dart';
// import 'package:medical_rep/features/admin/view/admin_page.dart';
// import 'package:medical_rep/features/home/views/home_screen.dart';
// import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
// import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';
// import '../viewmodels/login_cubit.dart';
// import '../data/repositories/auth_repository_impl.dart';
// import '../data/datasources/auth_remote_data_source.dart';
// import '../data/datasources/auth_local_data_source.dart';
// import 'widgets/login_hero_section.dart';
// import 'widgets/login_form_card.dart';
//
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       // تهيئة الـ Repository والـ Cubit
//       create: (_) => LoginCubit(
//         // بنستخدم الـ Implementation في الـ Data Layer
//         // عشان نغذي الـ Interface اللي الـ Cubit مستنيه
//         AuthRepositoryImpl(
//           AuthRemoteDataSource(),
//           AuthLocalDataSource(),
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundColor,
//         // استخدمنا BlocListener لمراقبة الحالات (States)
//         body: BlocListener<LoginCubit, LoginState>(
//           listener: (context, state) {
//             if (state is LoginLoading) {
//               // ممكن تظهري Loading Overlay هنا لو حابة
//             }
//            if (state is LoginSuccess) {
//   if (state.role == 'admin') {
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
//   } else {
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
//   }
// }
//             if (state is LoginFailure) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(state.message),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           child: const SingleChildScrollView(
//             physics: BouncingScrollPhysics(),
//             child: Column(
//               children: [
//                 LoginHeroSection(),
//                 LoginFormCard(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/home/views/home_screen.dart';
import 'package:medical_rep/features/admin/view/admin_page.dart'; // مسار صفحة الإدارة الصحيح
import '../viewmodels/login_cubit.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/auth_local_data_source.dart';
import 'widgets/login_hero_section.dart';
import 'widgets/login_form_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        AuthRepositoryImpl(AuthRemoteDataSource(), AuthLocalDataSource()),
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {

 
            if (state is LoginLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
            }


            if (state is LoginSuccess) {
              if (Navigator.canPop(context)) Navigator.of(context, rootNavigator: true).pop();

              final user = Supabase.instance.client.auth.currentUser;
              final email = user?.email?.toLowerCase().trim() ?? "";

              if (email == 'admin@medrep.com' || email == 'manar@gmail.com' || email.contains('admin')) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                      (route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                );
              }
            }

  
            if (state is LoginFailure) {
              if (Navigator.canPop(context)) Navigator.of(context, rootNavigator: true).pop();

              final currentUser = Supabase.instance.client.auth.currentUser;

       
              if (currentUser != null) {
                final email = currentUser.email?.toLowerCase().trim() ?? "";

                if (email == 'admin@medrep.com' || email == 'manar@gmail.com' || email.contains('admin')) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                        (route) => false,
                  );
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                }
                return; 
              }

          
              final errorMsg = state.message.toLowerCase();
              if (errorMsg.contains('profiles') || errorMsg.contains('pgrst116') || errorMsg.contains('coerce')) {

            
    
                final fallbackUser = Supabase.instance.client.auth.currentUser;
                final fallbackEmail = fallbackUser?.email?.toLowerCase().trim() ?? "";

                if (fallbackEmail == 'admin@medrep.com' || fallbackEmail == 'manar@gmail.com' || fallbackEmail.contains('admin')) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                        (route) => false,
                  );
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                }
                return; 
              }

          
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                LoginHeroSection(),
                LoginFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}