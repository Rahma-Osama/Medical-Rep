import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_remote_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';

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
}