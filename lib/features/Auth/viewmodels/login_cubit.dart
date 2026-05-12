import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:medical_rep/features/Auth/data/repositories/auth_repository_impl.dart';
import 'package:medical_rep/features/Auth/domain/repositories/auth_repository.dart';
import '../data/models/login_request_model.dart';

part 'login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  
 final AuthRepository authRepository;
   LoginCubit(this.authRepository) : super(LoginInitial());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  // حقن الـ Repository





  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());

    try {
      await authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      emit(LoginSuccess());
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