import 'package:flutter/material.dart';
import 'package:medical_rep/features/admin/data/data%20source/admin_data_source.dart';

class RepresentativePlanDetails extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Weekly Plan Details"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(visit['day_name'] ?? "Day", 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
                            Text(visit['visit_date'] ?? "", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Divider(height: 20),
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
            ),
          ),
          // منطقة الأزرار في الأسفل
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.done_all),
                    label: const Text("Approve Plan"),
                    onPressed: () async {
                      _updateAll(context, 'approved');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text("Reject Plan"),
                    onPressed: () async {
                      _updateAll(context, 'rejected');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة لتحديث كل الزيارات مرة واحدة
  Future<void> _updateAll(BuildContext context, String status) async {
    try {
      showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
      
      for (var visit in visits) {
        await AdminRemoteDataSource().updatePlanStatus(visit['id'].toString(), status);
      }
      
      if (context.mounted) {
        Navigator.pop(context); // إغلاق الـ Loading
        Navigator.pop(context); // العودة للشاشة السابقة
        onRefresh();
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      print("Error updating plan: $e");
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.indigoAccent),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? "N/A"),
        ],
      ),
    );
  }
}