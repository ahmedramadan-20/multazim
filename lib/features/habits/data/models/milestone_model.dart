import 'package:objectbox/objectbox.dart';
import '../../domain/entities/milestone.dart';

@Entity()
class MilestoneModel {
  @Id()
  int dbId = 0;

  @Unique()
  late String id;

  late String habitId;
  late String title;
  late int days;
  late DateTime reachedDate;

  MilestoneModel();

  factory MilestoneModel.fromEntity(Milestone milestone) {
    return MilestoneModel()
      ..id = milestone.id
      ..habitId = milestone.habitId
      ..title = milestone.title
      ..days = milestone.days
      ..reachedDate = milestone.reachedDate;
  }

  Milestone toEntity() {
    return Milestone(
      id: id,
      habitId: habitId,
      title: title,
      days: days,
      reachedDate: reachedDate,
    );
  }
}
