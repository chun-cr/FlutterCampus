import 'package:hive/hive.dart';
import '../../domain/models/user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      username: fields[1] as String,
      password: fields[2] as String,
      name: fields[3] as String,
      email: fields[4] as String,
      phone: fields[5] as String,
      type: UserType.fromString(fields[6] as String),
      studentId: fields[7] as String?,
      department: fields[8] as String?,
      avatar: fields[9] as String?,
      isLoggedIn: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.type.toString())
      ..writeByte(7)
      ..write(obj.studentId)
      ..writeByte(8)
      ..write(obj.department)
      ..writeByte(9)
      ..write(obj.avatar)
      ..writeByte(10)
      ..write(obj.isLoggedIn);
  }
}

void registerHiveAdapters() {
  Hive.registerAdapter(UserAdapter());
}
