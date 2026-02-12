import 'package:objectbox/objectbox.dart';
import '../../domain/entities/habit_event.dart';

@Entity()
class HabitEventModel {
  @Id()
  int dbId = 0;

  @Unique()
  late String id;

  @Index()
  late String habitId; // Indexed for fast lookups by habit

  @Index()
  late DateTime date; // Indexed for fast lookups by date

  late String statusName; // stored as string
  int? countValue;
  String? note;
  String? failReason;
  late DateTime createdAt;

  HabitEventModel();

  factory HabitEventModel.fromEntity(HabitEvent event) {
    return HabitEventModel()
      ..id = event.id
      ..habitId = event.habitId
      ..date = event.date
      ..statusName = event.status.name
      ..countValue = event.countValue
      ..note = event.note
      ..failReason = event.failReason
      ..createdAt = event.createdAt;
  }

  HabitEvent toEntity() {
    return HabitEvent(
      id: id,
      habitId: habitId,
      date: date,
      status: HabitEventStatus.values.firstWhere((e) => e.name == statusName),
      countValue: countValue,
      note: note,
      failReason: failReason,
      createdAt: createdAt,
    );
  }
}
