import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/admin/data/data%20source/admin_data_source.dart';

class RepresentativePlanDetails extends StatefulWidget {
  final String userId;
final VoidCallback onRefresh;

  const RepresentativePlanDetails({
    super.key,
    required this.userId,
    required this.onRefresh,
  });

  @override
  State<RepresentativePlanDetails> createState() => _RepresentativePlanDetailsState();
}

class _RepresentativePlanDetailsState extends State<RepresentativePlanDetails> {
  final TextEditingController _adminNotesController = TextEditingController();
  List<Map<String, dynamic>>? _currentVisits;

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

 Future<void> _processPlan(String status) async {
  if (_currentVisits == null) return;

  // إظهار اللودينج
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final notes = _adminNotesController.text.trim();
    
    // تنفيذ التحديث في سوبابيز
  for (var visit in _currentVisits!) {
  final String vid = visit['id'].toString();
  print("Updating Visit ID: $vid"); // عشان نشوف الـ ID في الـ Debug Console
  await AdminRemoteDataSource().updatePlanStatusWithNotes(
    visitId: vid,
    newStatus: status,
    adminNotes: notes,
  );
}

    // لو وصلنا هنا يبقى الداتا اتحدثت فعلاً في سوبابيز
    if (mounted) {
      setState(() {
        for (var v in _currentVisits!) {
          v['status'] = status; // بنحدث الحالة محلياً عشان الأزرار تختفي
        }
      });
      
      Navigator.pop(context); // إغلاق اللودينج
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plan $status Successfully!")),
      );
      
      widget.onRefresh(); // تحديث الهوم
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context); // إغلاق اللودينج في حالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // نطلب البيانات من السيرفر مباشرة بالـ ID
        future: AdminRemoteDataSource().getRepresentativePlan(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _currentVisits == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasData) {
            _currentVisits = snapshot.data;
          }

          if (_currentVisits == null || _currentVisits!.isEmpty) {
            return const Center(child: Text("No details found."));
          }

          // فحص دقيق للحالة (إهمال الحروف الكبيرة والصغيرة)
        bool isProcessed = _currentVisits!.every((v) {
    final s = v['status']?.toString().toLowerCase() ?? 'pending';
    return s == 'approved' || s == 'rejected';
  });

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    const CustomAppBar(label: 'Review Plan'),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildVisitCard(_currentVisits![index]),
                          childCount: _currentVisits!.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildAdminActionArea(isProcessed),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(visit['day_name'] ?? "Day", style: AppTextStyle.title.copyWith(fontSize: 16)),
                _buildStatusBadge(visit['status'] ?? 'pending'),
              ],
            ),
            const Divider(),
            Text("Doctor: ${visit['doctor_name']}", style: AppTextStyle.body),
            Text("Date: ${visit['visit_date']}", style: AppTextStyle.body),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionArea(bool isProcessed) {
    final currentStatus = _currentVisits?.first['status'] ?? 'Processed';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: isProcessed 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 10),
                Text(
                  "This plan has been $currentStatus",
                  style: AppTextStyle.title.copyWith(color: Colors.green, fontSize: 18),
                ),
                const SizedBox(height: 5),
                const Text("You have already taken action on this plan."),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _adminNotesController,
                  decoration: const InputDecoration(
                    hintText: "Add feedback...",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processPlan('approved'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processPlan('rejected'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: const Text("Reject", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: _getStatusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}