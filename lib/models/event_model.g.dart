// GENERATED CODE - DO NOT MODIFY BY HAND
// (hive_generator is incompatible with the current analyzer; kept in sync by hand.)

part of 'event_model.dart';

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventModel(
      id: fields[0] as int,
      eventTitle: fields[1] as String,
      eventDescription: fields[2] as String?,
      eventDate: fields[3] as DateTime,
      color: fields[4] as String,
      notify: fields[5] as bool? ?? false,
      reminder: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventTitle)
      ..writeByte(2)
      ..write(obj.eventDescription)
      ..writeByte(3)
      ..write(obj.eventDate)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.notify)
      ..writeByte(6)
      ..write(obj.reminder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
