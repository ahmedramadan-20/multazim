import 'package:objectbox/objectbox.dart';
import '../../domain/entities/milestone.dart';

@Entity()
class MilestoneModel {
  @Id()
  int dbId = 0;

  @Unique()
  late String id;

  /// FK
  late String habitId;

  /// e.g. 'streak_7', 'streak_30', 'streak_100'
  late String type;

  /// Actual streak count reached
  late int streakValue;

  /// When the milestone was achieved
  late DateTime achievedAt;

  /// For sync & ordering
  late DateTime createdAt;

  MilestoneModel();

  // ─────────────────────────────────────────────
  // Domain → Model
  // ─────────────────────────────────────────────
  factory MilestoneModel.fromEntity(Milestone milestone) {
    return MilestoneModel()
      ..id = milestone.id
      ..habitId = milestone.habitId
      ..type = milestone.type
      ..streakValue = milestone.streakValue
      ..achievedAt = milestone.achievedAt
      ..createdAt = milestone.createdAt;
  }

  // ─────────────────────────────────────────────
  // Model → Domain
  // ─────────────────────────────────────────────
  Milestone toEntity() {
    return Milestone(
      id: id,
      habitId: habitId,
      type: type,
      streakValue: streakValue,
      achievedAt: achievedAt,
      createdAt: createdAt,
    );
  }
}
