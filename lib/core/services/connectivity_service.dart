import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _controller.add(_checkListConnected(results));
    });
  }

  Future<bool> get isConnected async {
    // التعديل هنا: checkConnectivity بقت بترجع List
    final results = await Connectivity().checkConnectivity();
    return _checkListConnected(results);
  }

  bool _checkListConnected(List<ConnectivityResult> results) {
    if (results.isEmpty || (results.length == 1 && results.first == ConnectivityResult.none)) {
      return false;
    }
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() => _controller.close();
}