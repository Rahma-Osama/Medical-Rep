part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

// في ملف login_states.dart
class LoginSuccess extends LoginState {
  final String role; // إضافة الـ role هنا
  LoginSuccess(this.role);
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}