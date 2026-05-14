import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_rep/core/services/location_service.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/utils/location_parser.dart';
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

        // 🔹 فحص ومسح الخطة لو عدى عليها 5 أيام أول ما الشاشة تفتح
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
      body: Stack(
        children: [
          // 1️⃣ Stream شغال في الخلفية لتحديث الكاش
          StreamBuilder<List<weekly.VisitModel>>(
            stream:
            WeeklyPlanRemoteDataSourceImpl().getVisitsWithCache(),
            builder: (context, snapshot) {
              return const SizedBox.shrink();
            },
          ),

          // 2️⃣ UI بيقرأ من الكاش مباشرة
          ValueListenableBuilder(
            valueListenable:
            Hive.box<weekly.VisitModel>(
              'weekly_visits_box',
            ).listenable(),
            builder: (
                context,
                Box<weekly.VisitModel> box,
                _,
                ) {
              final List<weekly.VisitModel> allVisits =
              box.values.toList();

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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),

                          if (allVisits.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 60,
                                ),
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
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              itemCount: allVisits.length,
                              itemBuilder:
                                  (context, index) {
                                final visit =
                                allVisits[index];

                                String currentStatus =
                                    visit.status;

                                Color statusColor =
                                currentStatus
                                    .toLowerCase() ==
                                    'approved'
                                    ? Colors.green
                                    : currentStatus
                                    .toLowerCase() ==
                                    'rejected'
                                    ? Colors.red
                                    : Colors.orange;

                                // ✅ تاريخ النهارده
                                final today =
                                DateTime.now();

                                final todayFormatted =
                                    "${today.year.toString().padLeft(4, '0')}-"
                                    "${today.month.toString().padLeft(2, '0')}-"
                                    "${today.day.toString().padLeft(2, '0')}";

                                // ✅ هل الزيارة النهارده؟
                                final isToday =
                                    visit.date ==
                                        todayFormatted;

                                // ✅ هل Approved؟
                                final isApproved =
                                    currentStatus
                                        .toLowerCase() ==
                                        'approved';

                                // ✅ إظهار الزرار
                                final showStartVisitButton =
                                    isToday &&
                                        isApproved;

                                return Padding(
                                  padding:
                                  const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child:
                                  CutomPlanStatusCard(
                                    day:
                                    visit.dayName ??
                                        "No Day",

                                    date:
                                    visit.date ??
                                        "No Date",

                                    doctorName:
                                    visit.doctor ??
                                        "Unknown Doctor",

                                    specialty:
                                    visit.brick ??
                                        "No Specialty",

                                    shift:
                                    visit.shift,

                                    clinicName:
                                    "Clinic",

                                    location:
                                    visit.brick ??
                                        "No Location",

                                    status:
                                    currentStatus,

                                    color:
                                    statusColor,

                                    icon:
                                    currentStatus
                                        .toLowerCase() ==
                                        'approved'
                                        ? Icons
                                        .check_circle_rounded
                                        : Icons
                                        .access_time_filled_rounded,

                                    showStartVisitButton:
                                    showStartVisitButton,

                                    onStartVisit: () async {
                                      final locationService = LocationService();
                                      final validator = ValidateLocationUseCase(radiusInMeters: 100);

                                      try {
                                        // 1. get user location
                                        final position = await locationService.getCurrentPosition();
                                        // 2. check if clinic location exists
                                        if (visit.location == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Clinic location not found")),
                                          );
                                          return;
                                        }

                                        // 3. parse clinic location
                                        final clinic = LocationParser.parse(visit.location!);

                                        // 4. validate distance
                                        final isAllowed = validator(
                                          userLat: position.latitude,
                                          userLng: position.longitude,
                                          clinicLat: clinic.$1,
                                          clinicLng: clinic.$2,
                                        );

                                        if (!isAllowed) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("You are not at the clinic location"),
                                            ),
                                          );
                                          return;
                                        }

                                        // 5. proceed
                                        final activeVisit = visit_flow.VisitModel(
                                          visitId: DateTime.now().millisecondsSinceEpoch.toString(),
                                          doctorName: visit.doctor ?? "Unknown Doctor",
                                          specialty: visit.specialty ?? "General",
                                          clinicName: visit.clinicName ?? "Clinic",
                                          location: visit.location ?? "Unknown",
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
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Location error: $e")),
                                        );
                                      }
                                    },
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
        ],
      ),
    );
  }
}