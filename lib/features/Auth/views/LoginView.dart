import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/Auth/domain/repositories/auth_repository.dart';
import 'package:medical_rep/features/admin/view/admin_page.dart';
import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';
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
      // تهيئة الـ Repository والـ Cubit
     create: (_) => LoginCubit(
  // بنستخدم الـ Implementation في الـ Data Layer 
  // عشان نغذي الـ Interface اللي الـ Cubit مستنيه
  AuthRepositoryImpl(
    AuthRemoteDataSource(),
    AuthLocalDataSource(),
  ),
),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        // استخدمنا BlocListener لمراقبة الحالات (States)
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginLoading) {
              // ممكن تظهري Loading Overlay هنا لو حابة
            }
            if (state is LoginSuccess) {
             if (state.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreatePlanScreen()),
        );
      }
    }
            if (state is LoginFailure) {
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