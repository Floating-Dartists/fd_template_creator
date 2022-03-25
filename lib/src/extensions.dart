import 'dart:io' as io;

extension PathExtensiont on String {
  String formatToFilePath() {
    if (io.Platform.isWindows) {
      return replaceAll('/', '\\');
    }
    return this;
  }
}
