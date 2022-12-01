import 'dart:io' as io;

import 'package:fd_template_creator/src/command_wrapper.dart';
import 'package:fd_template_creator/src/errors/exceptions.dart';
import 'package:fd_template_creator/src/extensions.dart';
import 'package:fd_template_creator/src/logger.dart';
import 'package:fd_template_creator/src/template_model.dart';
import 'package:yaml/yaml.dart';

class CommandRunner {
  /// Run the script to create the template.
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
      for (final e in template.files) {
        await _copyPaste(
          source: '$workingDirectoryPath/temp/$e',
          target: '$workingDirectoryPath/$e',
        );
      }

      // Update files.
      for (final e in template.files) {
        final path = '$workingDirectoryPath/$e';
        if (path.isDirectory()) {
          await _changeAllInDirectory(
            directoryPath: path,
            oldPackageName: template.templateName,
            newPackageName: template.appName,
          );
        } else if (path.isFile()) {
          Logger.logInfo(
            "$path updated with new package name (${template.appName})",
          );
          await _changeAllInFile(
            path: path,
            oldValue: template.templateName,
            newValue: template.appName,
          );
        }
      }
    } on io.FileSystemException catch (e) {
      io.stderr.writeln(e.toString());
    } on MissingTemplateKeyException catch (e) {
      io.stderr.writeln(e.toString());
    } finally {
      _deleteTempFiles(workingDirectoryPath);
    }

    Logger.logInfo('You are good to go ! :)', lineBreak: true);
  }

  /// Run the flutter create command in the [workDir] with the parameters
  /// mentioned in the [template].
  void _createFlutterProject(TemplateModel template, String workDir) {
    Logger.logInfo(
      'Creating flutter project using your current flutter version...',
    );
    io.Process.runSync(
      'flutter',
      [
        'create',
        '--description',
        template.description,
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

  /// Retrieve the template from the [template] and copy it in the [workDir].
  ///
  /// If the template is a git repository, it will be cloned.
  void _retrieveTemplate(TemplateModel template, String workDir) {
    final templatePath = template.relativePath ?? template.gitRepository?.url;
    Logger.logInfo('Retrieving your template from $templatePath...');

    final gitUrl = template.gitRepository?.url;
    if (gitUrl != null) {
      final gitRef = template.gitRepository?.ref;
      io.Process.runSync(
        'git',
        [
          'clone',
          if (gitRef != null) ...[
            '--branch',
            gitRef,
          ],
          templatePath!,
          'temp',
        ],
        workingDirectory: workDir,
        runInShell: true,
      );
    } else {
      final result = io.Process.runSync(
        'cp',
        ['-r', templatePath!, 'temp'],
        workingDirectory: workDir,
        runInShell: true,
      );
      // Windows doesn't have the cp command, so we launch Powershell for our
      // command in this case.
      if (result.exitCode != 0) {
        io.Process.runSync(
          'powershell',
          ['cp', '-r', templatePath, 'temp'],
          workingDirectory: workDir,
          runInShell: true,
        );
      }
    }
  }

  /// Delete the temp files.
  void _deleteTempFiles(String workDir) {
    Logger.logInfo('Deleting temp files used for generation...');
    CommandWrapper.deleteSync('$workDir/temp');
  }

  /// Copy all the content of [source] and paste it in [target].
  Future<void> _copyPaste({
    required String source,
    required String target,
  }) async {
    CommandWrapper.deleteSync(target);
    Logger.logInfo('Copying $source to $target...');
    await CommandWrapper.copy(
      source: source,
      target: target,
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
    if (directory.existsSync()) {
      final files = directory.listSync();
      for (final file in files) {
        if (file is io.File) {
          await _changeAllInFile(
            path: file.path,
            oldValue: oldPackageName,
            newValue: newPackageName,
          );
        }
      }
      Logger.logInfo(
        "All files in $directoryPath updated with new package name ($newPackageName)",
      );
    } else {
      Logger.logWarning(
        "Missing directory $directoryPath in your template, it will be ignored",
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
