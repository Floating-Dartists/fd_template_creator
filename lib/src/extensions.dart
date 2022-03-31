import 'dart:io' as io;

extension PathExtension on String {
  bool isFile() {
    return io.File(this).existsSync();
  }

  bool isDirectory() {
    return io.Directory(this).existsSync();
  }
}
