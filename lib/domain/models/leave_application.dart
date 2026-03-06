import 'package:flutter/material.dart';
import '../../../presentation/theme/app_colors.dart';

/// 请假申请实体
class LeaveApplication {
  LeaveApplication({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.status,
    this.teacherId,
    this.teacherComment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      className: json['class_name'] as String,
      leaveType: json['leave_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String).toLocal(),
      endDate: DateTime.parse(json['end_date'] as String).toLocal(),
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'pending',
      teacherId: json['teacher_id'] as String?,
      teacherComment: json['teacher_comment'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final String leaveType; // '事假' / '病假' / '请假'
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final String status; // 'pending' / 'approved' / 'rejected'
  final String? teacherId;
  final String? teacherComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 状态文字标签
  String get statusLabel {
    return status == 'pending'
        ? '待审批'
        : status == 'approved'
            ? '已通过'
            : '已拒绝';
  }

  /// 状态颜色
  Color get statusColor {
    return status == 'pending'
        ? AppColors.warning
        : status == 'approved'
            ? AppColors.success
            : AppColors.error;
  }

  /// 日期范围文本
  String get dateRange {
    final s = _formatDate(startDate);
    final e = _formatDate(endDate);
    return '$s 至 $e';
  }

  /// 请假天数
  int get daysCount {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'student_id': studentId,
      'student_name': studentName,
      'class_name': className,
      'leave_type': leaveType,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate.toUtc().toIso8601String(),
      'status': status,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      if (teacherId != null) 'teacher_id': teacherId,
      if (teacherComment != null) 'teacher_comment': teacherComment,
    };
    // 新建时 id 为空，不传让数据库自动生成 uuid
    if (id.isNotEmpty) map['id'] = id;
    return map;
  }

  LeaveApplication copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? className,
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? status,
    String? teacherId,
    String? teacherComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveApplication(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      className: className ?? this.className,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      teacherId: teacherId ?? this.teacherId,
      teacherComment: teacherComment ?? this.teacherComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
