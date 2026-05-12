import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:medical_rep/features/Auth/data/repositories/auth_repository_impl.dart';
import 'package:medical_rep/features/Auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/login_request_model.dart';

part 'login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;
  LoginCubit(this.authRepository) : super(LoginInitial());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());

    try {
      // 1. تنفيذ عملية الدخول
      await authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 2. جلب بيانات المستخدم الحالي فوراً بعد الدخول
      final user = Supabase.instance.client.auth.currentUser;
      
      // 3. قراءة الـ role من الـ metadata (اللي أضفناها في السوبابيز)
      final String role = user?.userMetadata?['role'] ?? 'user'; 

      // 4. إرسال النجاح ومعاه الـ role
      emit(LoginSuccess(role));
      
    } catch (e) {
      emit(LoginFailure("خطأ في تسجيل الدخول: ${e.toString()}"));
    }
  }
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(LoginInitial());
  }


  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}