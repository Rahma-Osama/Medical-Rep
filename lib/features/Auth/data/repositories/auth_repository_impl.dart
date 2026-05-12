// data/repositories/auth_repository_impl.dart
import 'package:medical_rep/features/Auth/data/datasources/auth_local_data_source.dart';
import 'package:medical_rep/features/Auth/domain/entities/user_entity.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    
    // حفظ في الهايف
    await localDataSource.cacheUserSession(response.session?.accessToken);

    // تحويل الـ Response لموديل الـ Entity اللي الـ Domain بيفهمه
    return UserEntity(id: response.user!.id, email: response.user!.email!);
  }
}