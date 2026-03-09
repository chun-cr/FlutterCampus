/// 座位动态状态（由客户端计算，非数据库字段）
enum SeatStatus {
  available,     // 空闲，可预约
  occupied,      // 已被他人占用
  myReservation, // 当前用户已预约
}

/// 座位基础信息（对应 seat 表）
class Seat {
  const Seat({
    required this.id,
    required this.floor,
    required this.zone,
    required this.seatNumber,
    required this.hasPower,
    required this.hasWindow,
    required this.isEnabled,
    this.status = SeatStatus.available,
  });

  final String id;
  final String floor;
  final String zone;
  final int seatNumber;

  /// 是否有插座
  final bool hasPower;

  /// 是否靠窗
  final bool hasWindow;

  /// 是否启用（管理员可下架）
  final bool isEnabled;

  /// 动态计算的占用状态（客户端 merge 后赋值）
  final SeatStatus status;

  factory Seat.fromJson(Map<String, dynamic> json, {SeatStatus status = SeatStatus.available}) {
    return Seat(
      id: json['id'] as String,
      floor: json['floor'] as String,
      zone: json['zone'] as String,
      seatNumber: json['seat_number'] as int,
      hasPower: json['has_power'] as bool? ?? false,
      hasWindow: json['has_window'] as bool? ?? false,
      isEnabled: json['is_enabled'] as bool? ?? true,
      status: status,
    );
  }

  Seat copyWith({SeatStatus? status}) {
    return Seat(
      id: id,
      floor: floor,
      zone: zone,
      seatNumber: seatNumber,
      hasPower: hasPower,
      hasWindow: hasWindow,
      isEnabled: isEnabled,
      status: status ?? this.status,
    );
  }
}
