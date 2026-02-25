import 'package:objectbox/objectbox.dart';

/// Simple key-value store for app metadata.
/// Used for persisting lightweight flags like guest mode
/// without needing a separate package like shared_preferences.
@Entity()
class AppMetadataModel {
  @Id()
  int dbId = 0;

  @Unique()
  String key;

  String value;

  AppMetadataModel({this.dbId = 0, required this.key, required this.value});
}
