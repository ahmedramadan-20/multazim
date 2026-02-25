import 'dart:io';

void main() async {
  final libDir = Directory(
    'd:/developments/projects/flutter projects/multazim/lib',
  );
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  print('Total dart files: ${dartFiles.length}');

  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final lines = content.split('\n');

    // Audit 1: Missing dispose in StatefulWidget
    if (content.contains('extends State<')) {
      if (content.contains('initState()') && !content.contains('dispose()')) {
        print('[MEMORY LEAK] Missing dispose() in ${file.path}');
      }
    }

    // Audit 1: Async gaps (Future.delayed or async methods missing mounted check)
    // Basic heuristic: find 'await Future.delayed' followed by 'setState' or 'context.' without 'if (!mounted)'
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('await ') &&
          (content.substring(content.indexOf(line)).contains('setState') ||
              content.substring(content.indexOf(line)).contains('context.'))) {
        // Too complex for simple regex, will do manually or with better AST if needed.
        // Let's at least flag 'setState' after 'await'
      }
    }

    // Audit 2: Build method doing heavy compute or setState
    var inBuildMethod = false;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('Widget build(BuildContext context)')) {
        inBuildMethod = true;
      }
      if (inBuildMethod) {
        if (line.contains('setState(')) {
          print('[PERF] setState inside build() at ${file.path}:$i');
        }
        if (line.contains('context.watch<') || line.contains('context.read<')) {
          // check if in loop (e.g., inside ListView.builder)
        }
      }
      if (inBuildMethod && line.startsWith('  }')) {
        inBuildMethod = false; // crude end of build method
      }
    }

    // Audit 2: SingleChildScrollView -> Column without shrinkWrap or vice-versa
    if (content.contains('SingleChildScrollView') &&
        content.contains('Column')) {
      // Just flag for manual review
      if (content.contains('ListView') &&
          !content.contains('shrinkWrap: true')) {
        print(
          '[PERF] Unbounded list inside SingleChildScrollView at ${file.path}',
        );
      }
    }
  }
}
