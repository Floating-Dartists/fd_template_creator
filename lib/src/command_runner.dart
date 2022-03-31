import 'dart:io' as io;

import 'package:fd_template_creator/src/command_wrapper.dart';
import 'package:fd_template_creator/src/extensions.dart';
import 'package:fd_template_creator/src/logger.dart';
import 'package:fd_template_creator/src/template_model.dart';
import 'package:yaml/yaml.dart';

class CommandRunner {
  Future<void> create() async {
    final current = io.Directory.current;
    final workingDirectoryPath = current.path;

    try {
      final content = await io.File('$workingDirectoryPath/fd_template.yaml')
          .readAsString();
      final mapData = loadYaml(content) as YamlMap;
      final template = TemplateModel.fromYamlMap(mapData);

      _createFlutterProject(template, workingDirectoryPath);
      _retrieveTemplate(template, workingDirectoryPath);

      // Copy cloned files.
      final futures = <Future>[];
      for (final e in template.files) {
        futures.add(
          _copyPaste(
            source: '$workingDirectoryPath/temp/$e',
            target: '$workingDirectoryPath/$e',
          ),
        );
      }
      await Future.wait(futures);

      // Update files.
      for (final e in template.files) {
        final path = '$workingDirectoryPath/$e';
        if (path.isDirectory()) {
          _changeAllInDirectory(
            directoryPath: path,
            oldPackageName: template.templateName,
            newPackageName: template.appName,
          );
        } else if (path.isFile()) {
          _changeAllInFile(
            path: path,
            oldValue: template.templateName,
            newValue: template.appName,
          );
        }
      }
    } on io.FileSystemException catch (e) {
      io.stderr.writeln(e.toString());
    } finally {
      await _deleteTempFiles(workingDirectoryPath);
    }

    Logger.logInfo('You are good to go ! :)', lineBreak: true);
  }

  void _createFlutterProject(TemplateModel template, String workDir) {
    Logger.logInfo(
      'Creating flutter project using your current flutter version...',
    );
    io.Process.runSync(
      'flutter',
      [
        'create',
        '--org',
        template.organization,
        '--project-name',
        template.appName,
        '.',
      ],
      workingDirectory: workDir,
      runInShell: true,
    );
  }

  void _retrieveTemplate(TemplateModel template, String workDir) {
    final templatePath = template.relativePath ?? template.gitRepository?.url;
    Logger.logInfo(
      'Retrieving your template from $templatePath...',
    );

    io.Process.runSync(
      'git',
      ['clone', templatePath!, 'temp'],
      workingDirectory: workDir,
      runInShell: true,
    );
  }

  Future<void> _deleteTempFiles(String workDir) async {
    Logger.logInfo('Deleting temp files used for generation...');
    await CommandWrapper.delete('$workDir/temp');
    // io.Process.runSync('rm', ['-rf', '$workDir/temp']);
  }

  /// Copy all the content of [source] and paste it in [target].
  Future<void> _copyPaste({
    required String source,
    required String target,
  }) async {
    await CommandWrapper.delete(target);

    // io.Process.runSync('rm', ['-rf', target.formatToFilePath()]);
    io.Process.runSync(
      'cp',
      ['-r', source.formatToFilePath(), target.formatToFilePath()],
    );
  }

  /// Update recursively all imports in [directoryPath] from [oldPackageName] to
  /// [newPackageName].
  Future<void> _changeAllInDirectory({
    required String directoryPath,
    required String oldPackageName,
    required String newPackageName,
  }) async {
    final directory = io.Directory(directoryPath);
    final dirName = directory.path.split('/').last;
    if (directory.existsSync()) {
      final files = directory.listSync();

      final futures = <Future>[];
      for (final file in files) {
        if (file is io.File) {
          futures.add(
            _changeAllInFile(
              path: file.path,
              oldValue: oldPackageName,
              newValue: newPackageName,
            ),
          );
        }
      }
      await Future.wait(futures);
      Logger.logInfo(
        "All files in $dirName updated with new package name ($newPackageName)",
      );
    } else {
      Logger.logWarning(
        "Missing directory $dirName in your template, it will be ignored",
      );
    }
  }

  Future<void> _changeAllInFile({
    required String path,
    required String oldValue,
    required String newValue,
  }) async {
    try {
      final file = io.File(path);
      final content = await file.readAsString();
      if (content.contains(oldValue)) {
        final newContent = content.replaceAll(oldValue, newValue);
        await file.writeAsString(newContent);
      }
    } catch (e) {
      Logger.logError("Error updating file $path : $e");
    }
  }
}
