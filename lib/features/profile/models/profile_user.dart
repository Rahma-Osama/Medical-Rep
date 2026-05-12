/// Snapshot of the logged-in medical rep for the profile UI.
class ProfileUser {
  const ProfileUser({
    required this.fullName,
    required this.email,
    required this.repId,
    required this.roleTitle,
    required this.regionLabel,
    this.phone,
    this.territory,
  });

  final String fullName;
  final String email;
  final String repId;
  final String roleTitle;
  final String regionLabel;
  final String? phone;
  final String? territory;

  ProfileUser copyWith({
    String? fullName,
    String? email,
    String? repId,
    String? roleTitle,
    String? regionLabel,
    String? phone,
    String? territory,
  }) {
    return ProfileUser(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      repId: repId ?? this.repId,
      roleTitle: roleTitle ?? this.roleTitle,
      regionLabel: regionLabel ?? this.regionLabel,
      phone: phone ?? this.phone,
      territory: territory ?? this.territory,
    );
  }
}
