import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_rep/core/services/location_service.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/validate_location_usecase.dart';
import 'package:medical_rep/features/visit_flow/presentation/pages/active_visit_screen.dart';
import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_remote_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart';
import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';

import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart' as weekly;
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart' as visit_flow;

class WeeklyPlanningView extends StatelessWidget {
  const WeeklyPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<WeeklyPlanCubit>();
        cubit.clearCacheIfExpired();
        return cubit;
      },
      child: const _WeeklyPlanningBody(),
    );
  }
}

class _WeeklyPlanningBody extends StatelessWidget {
  const _WeeklyPlanningBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body:  Stack(
        children: [
          // 1️⃣ Stream يعمل في الخلفية لتحديث الكاش وربط اللوكيشن من جدول الدكاترة
          StreamBuilder<List<weekly.VisitModel>>(
            stream: WeeklyPlanRemoteDataSourceImpl().getVisitsWithCache(),
            builder: (context, snapshot) {
              return const SizedBox.shrink();
            },
          ),
      ValueListenableBuilder(
        valueListenable: Hive.box('weekly_visits_box').listenable(),
        builder: (context, Box box, _) {
          
          // ✅ التعديل السحري: تجميع زيارات الـ 5 أيام كلها في لستة واحدة
          List<VisitModel> allWeeklyVisits = [];

          // بنلف على الـ 5 أيام (من 0 لـ 4) ونجمع الزيارات بأمان
          for (int i = 0; i < 5; i++) {
            final dynamic dayData = box.get(i);
            if (dayData != null) {
              if (dayData is List) {
                allWeeklyVisits.addAll(dayData.map((item) => item as VisitModel).toList());
              } else if (dayData is VisitModel) {
                allWeeklyVisits.add(dayData);
              }
            }
          }

          // لو الأسبوع كله مفيش فيه أي زيارة متسيفة
          if (allWeeklyVisits.isEmpty) {
            return const _NoPlanWidget();
          }

          return CustomScrollView(
            slivers: [
              const CustomAppBar(
                label: 'Weekly Plan Status',
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allWeeklyVisits.length,
                        itemBuilder: (context, index) {
                          final visit = allWeeklyVisits[index];

                          String currentStatus = visit.status ?? "pending";
                          Color statusColor = _getStatusColor(currentStatus);

                          final today = DateTime.now();
                          final todayFormatted =
                              "${today.year.toString().padLeft(4, '0')}-"
                              "${today.month.toString().padLeft(2, '0')}-"
                              "${today.day.toString().padLeft(2, '0')}";

                          final isToday = visit.date == todayFormatted;
                          final isApproved = currentStatus.toLowerCase() == 'approved';
                          final isRejected = currentStatus.toLowerCase() == 'rejected';
                          final showStartVisitButton = isToday && isApproved;

                          final String feedback = visit.adminFeedback ?? ""; 

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CutomPlanStatusCard(
                                  day: visit.dayName ?? "No Day",
                                  date: visit.date ?? "No Date",
                                  doctorName: visit.doctor ?? "Unknown Doctor",
                                  specialty: visit.specialty ?? "No Specialty",
                                  shift: visit.shift ?? "AM",
                                  clinicName: visit.clinicName ?? "Clinic",
                                  location: visit.brick ?? "No Location",
                                  status: currentStatus,
                                  color: statusColor,
                                  icon: isApproved
                                      ? Icons.check_circle_rounded
                                      : isRejected 
                                          ? Icons.cancel_rounded 
                                          : Icons.access_time_filled_rounded,
                                  showStartVisitButton: showStartVisitButton,
                                  onStartVisit: () => _handleStartVisit(context, visit),
                                ),

                                if (isRejected && feedback.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.05),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.feedback_outlined, color: Colors.red, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Admin Note: $feedback",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (isRejected) 
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CreatePlanScreen(
                                                initialVisit: visit,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.edit_note, color: Colors.blue),
                                        label: const Text("Edit & Re-submit Plan"),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.blue),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
   ]), );
  }

 
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved' || 'done':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }


  Future<void> _handleStartVisit(BuildContext context, weekly.VisitModel visit) async {
    final locationService = LocationService();
    final validator = ValidateLocationUseCase(radiusInMeters: 100);

    try {
      final position = await locationService.getCurrentPosition();
      debugPrint("Use This Data To Doc Locatin for test");
      debugPrint(visit.toJson().toString());
      debugPrint(position.longitude.toString());
      debugPrint(position.latitude.toString());

      if (visit.lat == null || visit.long == null) {
        _showSnackBar(context, "موقع الطبيب غير متوفر في سجلات الدكاترة");
        return;
      }

      // 3. التحقق من المسافة
      final isAllowed = validator(
        userLat: position.latitude,
        userLng: position.longitude,
        clinicLat: visit.lat!,
        clinicLng: visit.long!,
      );

      if (!isAllowed) {
        _showSnackBar(context, "عفواً، أنت لست في موقع العيادة المطلوب");
        return;
      }

      // 4. إنشاء موديل الزيارة النشطة والانتقال للشاشة التالية
      final activeVisit = visit_flow.VisitModel(
        visitId: visit.visitId ?? '',
        doctorName: visit.doctor ?? "Unknown Doctor",
        specialty: visit.specialty ?? "General",
        clinicName: visit.clinicName ?? "Clinic",
        location: "${visit.lat},${visit.long}",
        targetProduct: visit.targetProduct ?? "Product",
        shift: visit.shift ?? "AM",
        startTime: DateTime.now(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveVisitScreen(visit: activeVisit),
        ),
      );
    } catch (e) {
      _showSnackBar(context, "خطأ في تحديد الموقع: $e");
    }
  }


  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _NoPlanWidget extends StatelessWidget {
  const _NoPlanWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: Text(
          "No plan yet",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}