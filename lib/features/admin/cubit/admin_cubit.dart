import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/features/admin/data/data%20source/admin_data_source.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRemoteDataSource _dataSource;

  AdminCubit(this._dataSource) : super(AdminInitial());

  Future<void> fetchAllRepresentativesPlans() async {
    // 1. فحص قبل البداية
    if (isClosed) {
      print("⚠️ AdminCubit is already closed! Cannot fetch.");
      return;
    }
    
    emit(AdminLoading());
    print("🔄 AdminCubit: Emitted Loading State...");

    try {
      print("📡 AdminCubit: Fetching data from Supabase...");
      final rawPlans = await _dataSource.getAllPlans();
      print("📥 AdminCubit: Data received from Supabase. Total rows: ${rawPlans.length}");

      // 2. تجميع آمن جداً لمنع الـ TypeError الكاستنج
      Map<String, List<Map<String, dynamic>>> groupedPlans = {};
      
      for (var plan in rawPlans) {
        if (plan is Map<String, dynamic>) {
          String userId = plan['user_id']?.toString() ?? "Unknown ID";
          if (!groupedPlans.containsKey(userId)) {
            groupedPlans[userId] = [];
          }
          groupedPlans[userId]!.add(plan);
        }
      }

      final userIds = groupedPlans.keys.toList();
      print("📊 AdminCubit: Grouped successfully. Total Representatives: ${userIds.length}");

      // 3. الفحص الذهبي قبل الـ Emit
      if (!isClosed) {
        emit(AdminSuccess(groupedPlans: groupedPlans, userIds: userIds));
        print("✅ AdminCubit: Emitted Success State successfully!");
      } else {
        print("⚠️ AdminCubit was closed before emitting Success.");
      }

    } catch (e, stacktrace) {
      print("❌ AdminCubit Catch Error: $e");
      print("🚨 StackTrace: $stacktrace");
      
      if (!isClosed) {
        emit(AdminError(e.toString()));
      }
    }
  }
}