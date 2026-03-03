/// 成绩实体
class Grade {
  Grade({
    required this.id,
    required this.userId,
    required this.courseName,
    required this.semester,
    required this.score,
    required this.gradePoint,
    required this.credit,
    this.status = GradeStatus.passed,
    required this.createdAt,
  });

  /// 从 Supabase JSON 解析 (snake_case)
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseName: json['course_name'] as String,
      semester: json['semester'] as String,
      score: (json['score'] as num).toDouble(),
      gradePoint: (json['grade_point'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      status: GradeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GradeStatus.passed,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  final String id;
  final String userId;
  final String courseName;
  final String semester; // e.g. '2025-2026-1'
  final double score; // 百分制成绩
  final double gradePoint; // 绩点
  final double credit; // 学分
  final GradeStatus status;
  final DateTime createdAt;

  /// 等级制显示，如 A / B+ / C
  String get letterGrade {
    if (score >= 90) return 'A';
    if (score >= 85) return 'A-';
    if (score >= 82) return 'B+';
    if (score >= 78) return 'B';
    if (score >= 75) return 'B-';
    if (score >= 72) return 'C+';
    if (score >= 68) return 'C';
    if (score >= 64) return 'C-';
    if (score >= 60) return 'D';
    return 'F';
  }

  /// 从百分制成绩计算4分制绩点
  static double calculateGradePoint(double score) {
    if (score >= 90) return 4.0;
    if (score >= 85) return 3.7;
    if (score >= 82) return 3.3;
    if (score >= 78) return 3.0;
    if (score >= 75) return 2.7;
    if (score >= 72) return 2.3;
    if (score >= 68) return 2.0;
    if (score >= 64) return 1.5;
    if (score >= 60) return 1.0;
    return 0.0;
  }

  Grade copyWith({
    String? id,
    String? userId,
    String? courseName,
    String? semester,
    double? score,
    double? gradePoint,
    double? credit,
    GradeStatus? status,
    DateTime? createdAt,
  }) {
    return Grade(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseName: courseName ?? this.courseName,
      semester: semester ?? this.semester,
      score: score ?? this.score,
      gradePoint: gradePoint ?? this.gradePoint,
      credit: credit ?? this.credit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 转换为 Supabase JSON (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_name': courseName,
      'semester': semester,
      'score': score,
      'grade_point': gradePoint,
      'credit': credit,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Grade($courseName: $score / $gradePoint)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Grade && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 成绩状态
enum GradeStatus {
  passed, // 通过
  failed, // 不及格
  retake, // 重修
  pending; // 成绩未出

  String get label {
    switch (this) {
      case GradeStatus.passed:
        return '通过';
      case GradeStatus.failed:
        return '不及格';
      case GradeStatus.retake:
        return '重修';
      case GradeStatus.pending:
        return '待出分';
    }
  }
}

/// 学期成绩汇总
class SemesterGradeSummary {
  SemesterGradeSummary({
    required this.semester,
    required this.gpa,
    required this.totalCredits,
    required this.courseCount,
    required this.grades,
  });

  /// 从成绩列表计算汇总
  factory SemesterGradeSummary.fromGrades(String semester, List<Grade> grades) {
    if (grades.isEmpty) {
      return SemesterGradeSummary(
        semester: semester,
        gpa: 0,
        totalCredits: 0,
        courseCount: 0,
        grades: [],
      );
    }

    double totalWeightedPoints = 0;
    double totalCredits = 0;
    for (final grade in grades) {
      totalWeightedPoints += grade.gradePoint * grade.credit;
      totalCredits += grade.credit;
    }

    return SemesterGradeSummary(
      semester: semester,
      gpa: totalCredits > 0 ? totalWeightedPoints / totalCredits : 0,
      totalCredits: totalCredits,
      courseCount: grades.length,
      grades: grades,
    );
  }

  factory SemesterGradeSummary.fromJson(Map<String, dynamic> json) {
    return SemesterGradeSummary(
      semester: json['semester'] as String,
      gpa: (json['gpa'] as num).toDouble(),
      totalCredits: (json['totalCredits'] as num).toDouble(),
      courseCount: json['courseCount'] as int,
      grades: (json['grades'] as List)
          .map((g) => Grade.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
  final String semester;
  final double gpa; // 学期绩点
  final double totalCredits; // 学期总学分
  final int courseCount; // 课程数量
  final List<Grade> grades;

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'gpa': gpa,
      'totalCredits': totalCredits,
      'courseCount': courseCount,
      'grades': grades.map((g) => g.toJson()).toList(),
    };
  }
}
