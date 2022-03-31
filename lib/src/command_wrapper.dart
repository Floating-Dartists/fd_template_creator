import 'dart:io' as io;

import 'package:fd_template_creator/src/extensions.dart';

abstract class CommandWrapper {
  static Future<void> delete(String path) async {
    if (path.isFile()) {
      final file = io.File(path);
      await file.delete(recursive: true);
    } else if (path.isDirectory()) {
      final dir = io.Directory(path);
      await dir.delete(recursive: true);
    }
  }
}
