/// 食堂/菜品实体
class Canteen {
  final String id;
  final String name;
  final String todayMenu; // 今日推荐菜品
  final double rating;
  final bool isOpen;
  final String? openTime; // e.g. '06:30 - 21:00'

  Canteen({
    required this.id,
    required this.name,
    required this.todayMenu,
    required this.rating,
    this.isOpen = true,
    this.openTime,
  });

  Canteen copyWith({
    String? id,
    String? name,
    String? todayMenu,
    double? rating,
    bool? isOpen,
    String? openTime,
  }) {
    return Canteen(
      id: id ?? this.id,
      name: name ?? this.name,
      todayMenu: todayMenu ?? this.todayMenu,
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'todayMenu': todayMenu,
      'rating': rating,
      'isOpen': isOpen,
      'openTime': openTime,
    };
  }

  factory Canteen.fromJson(Map<String, dynamic> json) {
    return Canteen(
      id: json['id'] as String,
      name: json['name'] as String,
      todayMenu: json['todayMenu'] as String,
      rating: (json['rating'] as num).toDouble(),
      isOpen: json['isOpen'] as bool? ?? true,
      openTime: json['openTime'] as String?,
    );
  }

  @override
  String toString() => 'Canteen($name, rating: $rating)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Canteen &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
