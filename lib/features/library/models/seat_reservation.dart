/// 座位预约记录（对应 seat_reservation 表，join seat 的基础信息）
class SeatReservation {
  const SeatReservation({
    required this.id,
    required this.userId,
    required this.seatId,
    required this.floor,
    required this.zone,
    required this.seatNumber,
    required this.hasPower,
    required this.hasWindow,
    required this.status,
    required this.reservationCode,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.checkedInAt,
    this.checkedOutAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String seatId;

  // --- join seat 表字段 ---
  final String floor;
  final String zone;
  final int seatNumber;
  final bool hasPower;
  final bool hasWindow;

  /// 状态：reserved / using / completed / cancelled / expired
  final String status;

  /// 6位大写预约码
  final String reservationCode;

  /// 预约日期
  final DateTime date;

  /// 开始时间，如 "09:00"
  final String startTime;

  /// 结束时间，如 "11:00"
  final String endTime;

  /// 用户签到时间
  final DateTime? checkedInAt;

  /// 用户签退时间
  final DateTime? checkedOutAt;

  final DateTime createdAt;

  /// 是否已超时未签到（超过开始时间 30 分钟且仍为 reserved）
  bool get isExpired {
    if (status != 'reserved') return false;
    final dateParts = startTime.split(':');
    final startDt = DateTime(
      date.year, date.month, date.day,
      int.parse(dateParts[0]), int.parse(dateParts[1]),
    );
    return DateTime.now().isAfter(startDt.add(const Duration(minutes: 30)));
  }

  /// 状态中文标签
  String get statusLabel {
    switch (status) {
      case 'reserved':  return '待签到';
      case 'using':     return '使用中';
      case 'completed': return '已完成';
      case 'cancelled': return '已取消';
      case 'expired':   return '已过期';
      default:          return status;
    }
  }

  /// 格式化预约时段，如 "09:00-11:00"
  String get timeRange => '$startTime-$endTime';

  /// 格式化预约信息，如 "三楼 A区 12号座 | 09:00-11:00"
  String get summaryText => '$floor $zone ${seatNumber}号座 | $timeRange';

  factory SeatReservation.fromJson(Map<String, dynamic> json) {
    final seatData = json['seat'] as Map<String, dynamic>?;

    return SeatReservation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      seatId: json['seat_id'] as String,
      floor: seatData?['floor'] as String? ?? json['floor'] as String? ?? '',
      zone: seatData?['zone'] as String? ?? json['zone'] as String? ?? '',
      seatNumber: seatData?['seat_number'] as int? ?? json['seat_number'] as int? ?? 0,
      hasPower: seatData?['has_power'] as bool? ?? false,
      hasWindow: seatData?['has_window'] as bool? ?? false,
      status: json['status'] as String? ?? 'reserved',
      reservationCode: json['reservation_code'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
      checkedOutAt: json['checked_out_at'] != null
          ? DateTime.parse(json['checked_out_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
