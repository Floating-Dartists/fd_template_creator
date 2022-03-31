import 'package:yaml/yaml.dart';

const _kDefaultDesc = 'A new Flutter project.';
const _kDefaultOrg = 'com.example';

class TemplateModel {
  final String appName;
  final String description;
  final String organization;
  final String templateName;
  final String? relativePath;
  final GitRepository? gitRepository;
  final List<String> files;

  TemplateModel({
    required this.appName,
    required this.description,
    required this.organization,
    required this.templateName,
    this.relativePath,
    this.gitRepository,
    required this.files,
  })  : assert(
          relativePath != null || gitRepository != null,
          'Either relativePath or gitRepository must be provided',
        ),
        assert(
          relativePath == null || gitRepository == null,
          'Only one of relativePath or gitRepository can be provided',
        );

  factory TemplateModel.fromYamlMap(YamlMap yamlMap) {
    final templateMap = yamlMap['template'] as YamlMap;
    return TemplateModel(
      appName: yamlMap['name'] as String,
      description: yamlMap['description'] as String? ?? _kDefaultDesc,
      organization: yamlMap['organization'] as String? ?? _kDefaultOrg,
      templateName: templateMap['name'] as String,
      relativePath: templateMap['path'] as String?,
      gitRepository: templateMap['git'] != null
          ? GitRepository.fromYamlMap(templateMap['git'] as YamlMap)
          : null,
      files: List<String>.from(templateMap['files'] as Iterable),
    );
  }
}

class GitRepository {
  final String url;
  final String? ref;

  GitRepository({required this.url, this.ref});

  factory GitRepository.fromYamlMap(YamlMap yamlMap) {
    return GitRepository(
      url: yamlMap['url'] as String,
      ref: yamlMap['ref'] as String?,
    );
  }
}
