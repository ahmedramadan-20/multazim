import 'package:objectbox/objectbox.dart';
import '../../domain/entities/streak_repair.dart';

@Entity()
class StreakRepairModel {
  @Id()
  int dbId = 0;

  @Unique()
  late String id;

  late String habitId;
  late DateTime date;
  late String reason;
  late DateTime createdAt;

  StreakRepairModel();

  factory StreakRepairModel.fromEntity(StreakRepair repair) {
    return StreakRepairModel()
      ..id = repair.id
      ..habitId = repair.habitId
      ..date = repair.date
      ..reason = repair.reason
      ..createdAt = repair.createdAt;
  }

  StreakRepair toEntity() {
    return StreakRepair(
      id: id,
      habitId: habitId,
      date: date,
      reason: reason,
      createdAt: createdAt,
    );
  }
}
