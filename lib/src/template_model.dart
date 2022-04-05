import 'package:fd_template_creator/src/errors/exceptions.dart';
import 'package:yaml/yaml.dart';

const kDefaultDesc = 'A new Flutter project.';
const kDefaultOrg = 'com.example';

/// A model class for a template, containing all data from the
/// `fd_template.yaml` file.
class TemplateModel {
  /// Project name.
  final String appName;

  /// Project description.
  ///
  /// Defaults to [kDefaultDesc].
  final String description;

  /// Organization name.
  ///
  /// Defaults to [kDefaultOrg].
  final String organization;

  /// Project template name.
  ///
  /// This will be used to replace the template name in the template files.
  final String templateName;

  /// Local path to the template.
  ///
  /// If this is `null` then the template will be retrieved from the git
  /// repository.
  final String? relativePath;

  /// Git repository to retrieve the template from.
  ///
  /// If this is `null` then the template will be retrieved from the local
  /// path.
  final GitRepository? gitRepository;

  /// Directory and file path to copy from the template.
  ///
  /// This is a [Set] of [String]s to avoid duplicate in path.
  final Set<String> files;

  /// Instanciate a new [TemplateModel].
  TemplateModel({
    required this.appName,
    required String? description,
    required String? organization,
    required this.templateName,
    this.relativePath,
    this.gitRepository,
    required this.files,
  })  : description = description ?? kDefaultDesc,
        organization = organization ?? kDefaultOrg,
        assert(
          relativePath != null || gitRepository != null,
          'Either relativePath or gitRepository must be provided',
        ),
        assert(
          relativePath == null || gitRepository == null,
          'Only one of relativePath or gitRepository can be provided',
        ),
        assert(files.isNotEmpty, 'files must not be empty');

  /// Instanciate a new [TemplateModel] from a [YamlMap].
  ///
  /// You want to use this method to instanciate a [TemplateModel] from a
  /// parsed `fd_template.yaml` file.
  factory TemplateModel.fromYamlMap(YamlMap yamlMap) {
    final templateMap = yamlMap['template'] as YamlMap;

    if (!yamlMap.containsKey('name')) {
      throw MissingTemplateKeyException('name');
    }
    if (!templateMap.containsKey('name')) {
      throw MissingTemplateKeyException('template name');
    }
    if (!templateMap.containsKey('files')) {
      throw MissingTemplateKeyException('template files');
    }

    return TemplateModel(
      appName: yamlMap['name'] as String,
      description: yamlMap['description'] as String?,
      organization: yamlMap['organization'] as String?,
      templateName: templateMap['name'] as String,
      relativePath: templateMap['path'] as String?,
      gitRepository: templateMap['git'] != null
          ? GitRepository.fromYamlMap(templateMap['git'] as YamlMap)
          : null,
      files: List<String>.from(templateMap['files'] as Iterable).toSet(),
    );
  }
}

class GitRepository {
  /// Git repository URL.
  final String url;

  /// Use this property if you want to depend on a specific commit, branch or
  /// tag.
  final String? ref;

  GitRepository({required this.url, this.ref});

  factory GitRepository.fromYamlMap(YamlMap yamlMap) {
    return GitRepository(
      url: yamlMap['url'] as String,
      ref: yamlMap['ref'] as String?,
    );
  }
}
