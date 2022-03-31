# fd_template_creator

A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

## Usage

```yaml
name: my_app
# description: A new Flutter project.
# organization: com.example
template:
  name: fd_template_creator
  # path: path/to/template
  git:
    url: https://github.com/Floating-Dartists/fd_template.git
    # ref: main
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
