import 'package:medical_rep/core/error/app_exception.dart';
import 'package:medical_rep/core/error/error_mapper.dart';
import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';

/// Loads profile data (replace with API / local cache integration).
class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<Result<ProfileUser>> getCurrentProfile() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      const user = ProfileUser(
        fullName: 'Ahmed Elsayed',
        email: 'ahmed.elsayed@pharma',
        repId: 'MR-2024-0042',
        roleTitle: 'Senior Medical Representative',
        regionLabel: 'Region 4',
        phone: '+20 100 000 0000',
        territory: 'Alexandria & North Coast',
      );
      return const Success(user);
    } catch (e, _) {
      return Failure(
        mapExceptionToFailure(
          e is AppException ? e : const ServerErrorException(),
        ),
      );
    }
  }
}
