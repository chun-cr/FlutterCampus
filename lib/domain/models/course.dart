/// 课程实体
class Course {
  // Hex color for timetable display

  Course({
    required this.id,
    required this.name,
    required this.teacher,
    required this.location,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.startWeek,
    required this.endWeek,
    this.color,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String? ?? '未命名课程',
      teacher: json['teacher'] as String? ?? '未知教师',
      location: json['location'] as String? ?? '未知地点',
      weekday: json['weekday'] as int? ?? 1,
      startTime: json['start_time'] as String? ?? '08:00',
      endTime: json['end_time'] as String? ?? '09:00',
      startWeek: json['start_week'] as int? ?? 1,
      endWeek: json['end_week'] as int? ?? 16,
      color: json['color'] as String?,
    );
  }
  final String id;
  final String name;
  final String teacher;
  final String location;
  final int weekday; // 1=周一 ... 7=周日
  final String startTime; // e.g. '08:00'
  final String endTime; // e.g. '09:40'
  final int startWeek;
  final int endWeek;
  final String? color;

  /// 格式化时间段，如 '08:00 - 09:40'
  String get timeSlotDisplay => '$startTime - $endTime';

  /// 格式化周次范围，如 '第1-16周'
  String get weekRangeDisplay => '第$startWeek-$endWeek周';

  Course copyWith({
    String? id,
    String? name,
    String? teacher,
    String? location,
    int? weekday,
    String? startTime,
    String? endTime,
    int? startWeek,
    int? endWeek,
    String? color,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'location': location,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
      'start_week': startWeek,
      'end_week': endWeek,
      'color': color,
    };
  }

  @override
  String toString() => 'Course($name, $timeSlotDisplay @ $location)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
