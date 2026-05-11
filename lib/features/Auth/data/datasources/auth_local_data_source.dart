// data/datasources/auth_local_data_source.dart
import 'package:hive/hive.dart';

class AuthLocalDataSource {
  final String boxName = 'authBox';

  // حفظ التوكن أو حالة تسجيل الدخول
  Future<void> cacheUserSession(String? token) async {
    var box = await Hive.openBox(boxName);
    await box.put('token', token);
  }

  // التأكد هل المستخدم مسجل دخول أم لا
  bool isUserLoggedIn() {
    var box = Hive.box(boxName);
    return box.get('token') != null;
  }
}

// data/datasources/auth_remote_data_source.dart
