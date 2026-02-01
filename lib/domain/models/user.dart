class User {
  final String id;
  final String username;
  final String password;
  final String name;
  final String email;
  final String phone;
  final UserType type;
  final String? studentId;
  final String? department;
  final String? avatar;
  final bool isLoggedIn;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    this.studentId,
    this.department,
    this.avatar,
    this.isLoggedIn = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? name,
    String? email,
    String? phone,
    UserType? type,
    String? studentId,
    String? department,
    String? avatar,
    bool? isLoggedIn,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      avatar: avatar ?? this.avatar,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type.toString(),
      'studentId': studentId,
      'department': department,
      'avatar': avatar,
      'isLoggedIn': isLoggedIn,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
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
      isLoggedIn: json['isLoggedIn'] ?? false,
    );
  }
}

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
