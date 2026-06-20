import 'package:hive/hive.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.dueAt,
    required this.accent,
    this.note = '',
    this.isCompleted = false,
    this.completedAt,
    this.order = 0,
  });

  final String id;
  final String title;
  final String category;
  final String note;
  final DateTime dueAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final int accent;
  final int order;

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueAt);

  Task copyWith({
    String? id,
    String? title,
    String? category,
    String? note,
    DateTime? dueAt,
    bool? isCompleted,
    DateTime? completedAt,
    int? accent,
    int? order,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      note: note ?? this.note,
      dueAt: dueAt ?? this.dueAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      accent: accent ?? this.accent,
      order: order ?? this.order,
    );
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      note: fields[3] as String? ?? '',
      dueAt: fields[4] as DateTime,
      isCompleted: fields[5] as bool? ?? false,
      completedAt: fields[6] as DateTime?,
      accent: fields[7] as int? ?? 0xFFFF7A59,
      order: fields[8] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.dueAt)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.accent)
      ..writeByte(8)
      ..write(obj.order);
  }
}
