class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? studentId;
  final String? department;
  final String? organizationName;
  final String? location;
  final int points;
  final DateTime createdAt;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.department,
    this.organizationName,
    this.location,
    this.points = 0,
    required this.createdAt,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'studentId': studentId,
      'department': department,
      'organizationName': organizationName,
      'location': location,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.student,
      ),
      studentId: map['studentId'],
      department: map['department'],
      organizationName: map['organizationName'],
      location: map['location'],
      points: map['points'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isVerified: map['isVerified'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? studentId,
    String? department,
    String? organizationName,
    String? location,
    int? points,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      organizationName: organizationName ?? this.organizationName,
      location: location ?? this.location,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

enum UserRole {
  student,
  cafeteria,
  ngo,
  admin,
}

