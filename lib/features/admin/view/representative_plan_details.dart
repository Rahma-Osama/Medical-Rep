import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/admin/data/data%20source/admin_data_source.dart';

class RepresentativePlanDetails extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> visits;
  final VoidCallback onRefresh;

  const RepresentativePlanDetails({
    super.key,
    required this.userId,
    required this.visits,
    required this.onRefresh,
  });

  @override
  State<RepresentativePlanDetails> createState() => _RepresentativePlanDetailsState();
}

class _RepresentativePlanDetailsState extends State<RepresentativePlanDetails> {
  // دالة مساعدة لتحديد لون الحالة
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange; // للحالة pending أو null
    }
  }

  @override
  Widget build(BuildContext context) {
    // التحقق هل يوجد أي زيارة لسه pending عشان نظهر الأزرار أو نخفيها
    bool hasPendingVisits = widget.visits.any((v) => v['status'] == 'pending' || v['status'] == null);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const CustomAppBar(label: 'Plan Details'),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final visit = widget.visits[index];
                        final String currentStatus = visit['status'] ?? 'pending';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.grayColor.withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      visit['day_name'] ?? "Day",
                                      style: AppTextStyle.title.copyWith(
                                        color: AppColors.primaryColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    // عرض حالة الزيارة كـ Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(currentStatus).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _getStatusColor(currentStatus)),
                                      ),
                                      child: Text(
                                        currentStatus.toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusColor(currentStatus),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  visit['visit_date'] ?? "",
                                  style: AppTextStyle.body.copyWith(color: AppColors.grayColor, fontSize: 12),
                                ),
                                const Divider(height: 24, thickness: 0.5),
                                _buildInfoRow(Icons.local_hospital, "Doctor", visit['doctor_name']),
                                _buildInfoRow(Icons.access_time, "Shift", visit['shift']),
                                _buildInfoRow(Icons.category, "Type", visit['visit_type']),
                                if (visit['notes'] != null && visit['notes'].toString().isNotEmpty)
                                  _buildInfoRow(Icons.note, "Notes", visit['notes']),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: widget.visits.length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // منطقة الأزرار: تظهر فقط إذا كانت هناك زيارات معلقة
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: hasPendingVisits 
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("Approve All", style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => _updateAllStatus(context, 'approved'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.highlight_off),
                          label: const Text("Reject All", style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => _updateAllStatus(context, 'rejected'),
                        ),
                      ),
                    ],
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.done_all, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          "This plan has been processed",
                          style: AppTextStyle.body.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAllStatus(BuildContext context, String status) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>  Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      );

      // تحديث كل زيارة في سوبا بيز
      for (var visit in widget.visits) {
        await AdminRemoteDataSource().updatePlanStatus(visit['id'].toString(), status);
      }

      if (context.mounted) {
        Navigator.pop(context); // إغلاق الـ Loading
        widget.onRefresh();    // تحديث البيانات في الشاشة الرئيسية للإدمن
        Navigator.pop(context); // العودة للشاشة السابقة
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Plan $status successfully"), backgroundColor: status == 'approved' ? Colors.green : Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      debugPrint("Error updating plan: $e");
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text("$label: ", style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: AppTextStyle.body.copyWith(color: AppColors.grayColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}