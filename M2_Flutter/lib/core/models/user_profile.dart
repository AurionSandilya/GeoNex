import '../constants/app_constants.dart';

class UserProfile {
  final String id;
  final String name;
  final String emailOrPhone;
  final UserRole role;
  final String designation;
  final String assignedRegion;
  final String badgeNumber;

  const UserProfile({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    required this.role,
    required this.designation,
    required this.assignedRegion,
    required this.badgeNumber,
  });

  String get roleDisplayName {
    switch (role) {
      case UserRole.authority:
        return 'Disaster Authority / Official';
      case UserRole.fieldOfficer:
        return 'Field Officer / Inspector';
      case UserRole.citizen:
        return 'Citizen / Volunteer';
    }
  }
}
