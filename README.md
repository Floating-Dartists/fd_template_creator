# fd_template_creator

A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

## Usage

Create a file `fd_template_creator.yaml` in the root of your project.

```yaml
name: my_app
template:
  name: fd_template
  git:
    url: https://github.com/Floating-Dartists/fd_template.git
  files:
    - .github/
    - lib/
    - assets/
    - test/
    - analysis_options.yaml
    - dart_test.yaml
    - pubspec.yaml
```

## Credits

* Inspired by the package [app_starter](https://pub.dev/packages/app_starter)
