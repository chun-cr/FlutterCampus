import 'package:supabase_flutter/supabase_flutter.dart' as sup;

enum UserType {
  student,
  teacher,
  staff;

  @override
  String toString() {
    return 'UserType.$name';
  }

  static UserType fromString(String value) {
    return values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => UserType.student,
    );
  }
}

class User {
  final String id;
  final String username;
  final String name;
  final String email;
  final String phone;
  final UserType type;
  final String? studentId;
  final String? department;
  final String? avatar;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    this.studentId,
    this.department,
    this.avatar,
  });

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? phone,
    UserType? type,
    String? studentId,
    String? department,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type.toString(),
      'studentId': studentId,
      'department': department,
      'avatar': avatar,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      type: UserType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => UserType.student,
      ),
      studentId: json['studentId'],
      department: json['department'],
      avatar: json['avatar'],
    );
  }

  factory User.fromSupabase(sup.User supabaseUser) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email!,
      username: supabaseUser.userMetadata?['username'] ?? supabaseUser.email!,
      name: supabaseUser.userMetadata?['name'] ?? '',
      phone: supabaseUser.phone ?? '',
      type: UserType.fromString(supabaseUser.userMetadata?['type'] ?? 'student'),
      studentId: supabaseUser.userMetadata?['student_id'],
      department: supabaseUser.userMetadata?['department'],
      avatar: supabaseUser.userMetadata?['avatar'],
    );
  }
}
