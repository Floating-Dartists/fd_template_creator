import 'dart:io' as io;

String fixture(String name) => io.File('test/assets/$name').readAsStringSync();
