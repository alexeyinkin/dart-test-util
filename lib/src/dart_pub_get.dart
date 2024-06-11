import 'dart:io';

import 'package:test/test.dart';

import 'stream_list_int.dart';

/// Runs 'dart pub get' and expect it to succeed.
Future<void> dartPubGet({
  String? workingDirectory,
}) async {
  final process = await Process.start(
    'dart',
    [
      'pub',
      'get',
    ],
    workingDirectory: workingDirectory,
  );

  final exitCode = await process.exitCode;
  final stderr = await process.stderr.toJointString();

  expect(exitCode, 0, reason: stderr);
  expect(stderr, '');
}
