import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/medical_model.dart';

class MedicalRemoteDataSource {
  final supabase = Supabase.instance.client;

  Future<List<MedicalModel>> getDoctors() async {
    final response = await supabase.from('doctors').select();
    return (response as List).map((e) => MedicalModel.fromJson(e)).toList();
  }
}