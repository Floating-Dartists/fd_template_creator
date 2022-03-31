import 'dart:io' as io;

extension PathExtension on String {
  String formatToFilePath() {
    if (io.Platform.isWindows) {
      return replaceAll('/', '\\');
    }
    return this;
  }

  bool isFile() {
    return io.File(this).existsSync();
  }

  bool isDirectory() {
    return io.Directory(this).existsSync();
  }
}
