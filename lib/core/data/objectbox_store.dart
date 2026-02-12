import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../objectbox.g.dart'; // Created by build_runner

class ObjectBoxStore {
  late final Store store;

  ObjectBoxStore._create(this.store);

  static Future<ObjectBoxStore> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docsDir.path, 'multazim-db'),
    );
    return ObjectBoxStore._create(store);
  }
}
