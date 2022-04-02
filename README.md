# fd_template_creator

[![Pub Version](https://img.shields.io/pub/v/fd_template_creator)](https://pub.dev/packages/fd_template_creator)
[![Test workflow](https://github.com/Floating-Dartists/fd_template_creator/actions/workflows/dart.yml/badge.svg)](https://github.com/Floating-Dartists/fd_template_creator/actions/workflows/dart.yml)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

A Dart script to generate a template for a Flutter project from a boilerplate code repository.

This package will generate a template by using the `flutter create` command, then copying files from a code repo to replace the generated files.

## Usage

* Activate the package globally:

```bash
dart pub global activate fd_template_creator
```

* Create a file `fd_template_creator.yaml` in the root of your project:

```yaml
# Project name
name: my_app
# Project description (optional)
# description: My app description
template:
  # Template name (used to replace package import)
  name: fd_template
  # Git repository to clone
  git:
    url: https://github.com/Floating-Dartists/fd_template.git
    # If you want to depend on a specific commit, branch or tag, you
    # can use a ref key (Not yet supported)
    # ref: main
  # Local path to the template (Not yet supported)
  # path: path/to/fd_template
  # List of the files or folders to copy from the template
  files:
    - .github/
    - lib/
    - assets/
    - test/
    - analysis_options.yaml
    - dart_test.yaml
    - pubspec.yaml
```

* Run the package from the root of your project:

```bash
dart pub global run fd_template_creator
```

**Note:** If you want to use the package you will need to have Flutter installed on your machine.

## TODO

* Support git references
* Support local paths
* Better error management
* Add some tests

## Credits

* Inspired by the package [app_starter](https://pub.dev/packages/app_starter)
* Developed by [TesteurManiak](https://github.com/TesteurManiak) & [the Floating Dartists](https://github.com/Floating-Dartists)
