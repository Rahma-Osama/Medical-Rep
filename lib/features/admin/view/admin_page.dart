import 'package:flutter/material.dart';
import 'package:medical_rep/features/Auth/views/LoginView.dart';
import 'package:medical_rep/features/admin/data/data%20source/admin_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'representative_plan_details.dart'; // تأكدي من عمل الملف التالي بنفس الاسم

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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Manager Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: AdminRemoteDataSource().getAllPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
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
            return const Center(child: Text("No plans submitted yet.", style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              String userId = userIds[index];
              List<Map<String, dynamic>> visits = groupedPlans[userId]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigoAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text("Rep ID: ${userId.substring(0, 8)}...", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Total Visits in Plan: ${visits.length}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.indigo),
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
          );
        },
      ),
    );
  }
}