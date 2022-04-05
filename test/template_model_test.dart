import 'package:fd_template_creator/src/errors/exceptions.dart';
import 'package:fd_template_creator/src/template_model.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:yaml/yaml.dart';

import 'utils/fixture_reader.dart';

void main() {
  group('TemplateModel', () {
    group('fromYamlMap', () {
      test('parse: fd_template.yaml', () async {
        final yaml = loadYaml(fixture('template.yaml')) as YamlMap;
        final template = TemplateModel.fromYamlMap(yaml);

        expect(template.appName, 'my_app');
        expect(template.description, kDefaultDesc);
        expect(template.organization, kDefaultOrg);
        expect(template.templateName, 'fd_template');
        expect(template.relativePath, isNull);
        expect(
          template.gitRepository?.url,
          'https://github.com/Floating-Dartists/fd_template.git',
        );
        expect(template.gitRepository?.ref, 'main');
      });

      test('no project name', () {
        final yaml = loadYaml(fixture('template_no_name.yaml')) as YamlMap;
        expect(
          () => TemplateModel.fromYamlMap(yaml),
          throwsA(isA<MissingTemplateKeyException>()),
        );
      });

      test('no template files', () {
        final yaml = loadYaml(fixture('template_no_files.yaml')) as YamlMap;
        expect(
          () => TemplateModel.fromYamlMap(yaml),
          throwsA(isA<MissingTemplateKeyException>()),
        );
      });
    });
  });
}
