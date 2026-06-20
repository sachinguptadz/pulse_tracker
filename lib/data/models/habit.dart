import 'package:hive/hive.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.target,
    required this.progress,
    required this.accent,
    this.streak = 0,
  });

  final String id;
  final String name;
  final String category;
  final double target;
  final double progress;
  final int streak;
  final int accent;

  double get ratio => target <= 0 ? 0 : (progress / target).clamp(0, 1);

  Habit copyWith({
    String? id,
    String? name,
    String? category,
    double? target,
    double? progress,
    int? streak,
    int? accent,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
      accent: accent ?? this.accent,
    );
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 2;

  @override
  Habit read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      target: fields[3] as double,
      progress: fields[4] as double,
      streak: fields[5] as int? ?? 0,
      accent: fields[6] as int? ?? 0xFFFF7A59,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.target)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.streak)
      ..writeByte(6)
      ..write(obj.accent);
  }
}
