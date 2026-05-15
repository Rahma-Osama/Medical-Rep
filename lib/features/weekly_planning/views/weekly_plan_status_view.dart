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
import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';

import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart'
as weekly;

import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart'
as visit_flow;

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
      body: StreamBuilder<List<VisitModel>>(

        stream: WeeklyPlanRemoteDataSourceImpl().getVisitsWithCache(), 
        builder: (context, snapshot) {
          
       
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

 
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

         
          final List<VisitModel> allVisits = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              const CustomAppBar(label: 'Weekly Plan Status'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      
                      if (allVisits.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Text(
                              "No Plan Yet",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allVisits.length,
                          itemBuilder: (context, index) {
                            final visit = allVisits[index];
                            
                       
                            String currentStatus = visit.status ?? 'pending';
                            
                            Color statusColor = currentStatus.toLowerCase() == 'approved' 
                                ? Colors.green : currentStatus.toLowerCase() == 'rejected' 
                                ? Colors.red : Colors.orange;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CutomPlanStatusCard(
                                day: visit.dayName ?? "No Day", 
                                date: visit.date ?? "No Date",
                                doctorName: visit.doctor ?? "Unknown Doctor",
                                specialty: visit.brick ?? "No Specialty",
                                shift: visit.shift,
                                clinicName: "Clinic",
                                location: visit.brick ?? "No Location",
                                status: currentStatus, 
                                color: statusColor, 
                                icon: currentStatus.toLowerCase() == 'approved' 
                                    ? Icons.check_circle_rounded : Icons.access_time_filled_rounded, 
                                onStartVisit: () {},
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
    );
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
        visitId: visit.visitId??'',
        doctorName: visit.doctor ?? "Unknown Doctor",
        specialty: visit.specialty ?? "General",
        clinicName: visit.clinicName ?? "Clinic",
        location: "${visit.lat},${visit.long}",
        targetProduct: visit.targetProduct ?? "Product",
        shift: visit.shift,
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
          "لا توجد خطة حالية أو انتهت صلاحية الخمس أيام.\nبرجاء إدخال خطة جديدة.",
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