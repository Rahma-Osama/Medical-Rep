import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/Auth/views/LoginView.dart';
import 'package:medical_rep/features/admin/data/data%20source/admin_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'representative_plan_details.dart'; 

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // توحيد لون الخلفية
      body: CustomScrollView(
        slivers: [
          // استخدام الكاستم بار بتاعك مع إضافة زر الخروج
          CustomAppBar(
            label: 'Manager Dashboard',
            actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        // تنفيذ خروج من سوبا بيز
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          // العودة لصفحة تسجيل الدخول ومسح كل الـ stack
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
            
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: AdminRemoteDataSource().getAllPlans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: AppTextStyle.body));
                }

                final rawPlans = snapshot.data ?? [];
                
                // تجميع الزيارات حسب الـ User ID
                Map<String, List<Map<String, dynamic>>> groupedPlans = {};
                for (var plan in rawPlans) {
                  String userId = plan['user_id'] ?? "Unknown ID";
                  if (!groupedPlans.containsKey(userId)) {
                    groupedPlans[userId] = [];
                  }
                  groupedPlans[userId]!.add(plan);
                }

                final userIds = groupedPlans.keys.toList();

                if (userIds.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        "No plans submitted yet.", 
                        style: AppTextStyle.body.copyWith(color: AppColors.grayColor)
                      )
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Representatives Plans",
                        style: AppTextStyle.title.copyWith(color: AppColors.grayColor),
                      ),
                      const SizedBox(height: 15),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userIds.length,
                        itemBuilder: (context, index) {
                          String userId = userIds[index];
                          List<Map<String, dynamic>> visits = groupedPlans[userId]!;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0, // خليناه Flat عشان يمشي مع ستايل الـ Cards التانية
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.grayColor.withOpacity(0.2)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child:  Icon(Icons.person, color: AppColors.primaryColor),
                              ),
                              title: Text(
                                "Rep ID: ${userId.substring(0, 8).toUpperCase()}", 
                                style: AppTextStyle.title.copyWith(fontSize: 16)
                              ),
                              subtitle: Text(
                                "Total Visits: ${visits.length}", 
                                style: AppTextStyle.body.copyWith(color: AppColors.grayColor)
                              ),
                              trailing:  Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RepresentativePlanDetails(
                                      userId: userId,
                                      visits: visits,
                                      onRefresh: _refresh,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}