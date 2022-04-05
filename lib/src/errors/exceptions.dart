class TemplateException implements Exception {
  final String message;

  TemplateException(this.message);

  @override
  String toString() => "TemplateException: $message";
}

class MissingTemplateKeyException extends TemplateException {
  MissingTemplateKeyException(String key) : super('Missing key: $key');
}
