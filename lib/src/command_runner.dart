import 'dart:io' as io;

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
      // for (final e in template.files) {
      //   _copyPaste(
      //     source: '$workingDirectoryPath/temp/$e',
      //     target: '$workingDirectoryPath/$e',
      //   );
      // }
    } on io.FileSystemException catch (e) {
      io.stderr.writeln(e.toString());
    } finally {
      _deleteTempFiles(workingDirectoryPath);
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
        template.name,
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

  void _deleteTempFiles(String workDir) {
    if (io.Platform.isWindows) {
      Logger.logWarning(
        'You are on Windows. Please delete the temp folder manually.',
      );
    } else {
      Logger.logInfo('Deleting temp files used for generation...');
      io.Process.runSync('rm', ['-rf', '$workDir/temp']);
    }
  }

  /// Copy all the content of [source] and paste it in [target].
  void _copyPaste({
    required String source,
    required String target,
  }) {
    io.Process.runSync('rm', ['-rf', target.formatToFilePath()]);
    io.Process.runSync(
      'cp',
      ['-r', source.formatToFilePath(), target.formatToFilePath()],
    );
  }
}

extension on String {
  String formatToFilePath() {
    if (io.Platform.isWindows) {
      return replaceAll('/', '\\');
    }
    return this;
  }
}
