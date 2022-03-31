import 'dart:io' as io;

import 'package:fd_template_creator/src/extensions.dart';

abstract class CommandWrapper {
  static void deleteSync(String path) {
    if (path.isFile()) {
      final file = io.File(path);
      return file.deleteSync();
    } else if (path.isDirectory()) {
      final directory = io.Directory(path);
      return directory.deleteSync(recursive: true);
    }
  }

  static Future<void> copy({
    required String source,
    required String target,
  }) async {
    if (source.isFile()) {
      final file = io.File(source);
      final cleanedPath = file.path.replaceFirst(source, target);

      final newFile = io.File(cleanedPath);
      await newFile.create(recursive: true);
      await file.copy(cleanedPath);
    } else if (source.isDirectory()) {
      final files = await allDirectoryFiles(source);
      for (final file in files) {
        final cleanedPath = file.path.replaceFirst(source, target);
        final newFile = io.File(cleanedPath);
        await newFile.create(recursive: true);
        await file.copy(cleanedPath);
      }
    }
  }

  static Future<List<io.File>> allDirectoryFiles(String dirPath) {
    final frameworkFilePaths = <io.File>[];
    return io.Directory(dirPath)
        .list(
          recursive: true,
          followLinks: false,
        )
        .listen((entity) {
          final file = io.File(entity.path);
          if (file.existsSync()) {
            frameworkFilePaths.add(file);
          }
        })
        .asFuture()
        .then((_) => frameworkFilePaths);
  }
}
