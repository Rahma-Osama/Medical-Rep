import 'package:flutter/foundation.dart';

@immutable
abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminSuccess extends AdminState {
  // بنخزن الداتا متجمعة وجاهزة للـ UI فوراً
  final Map<String, List<Map<String, dynamic>>> groupedPlans;
  final List<String> userIds;

  AdminSuccess({required this.groupedPlans, required this.userIds});
}

class AdminError extends AdminState {
  final String errorMessage;
  AdminError(this.errorMessage);
}