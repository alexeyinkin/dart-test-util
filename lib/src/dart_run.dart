import 'dart:io';

import 'package:test/test.dart';

import 'int_stream.dart';

/// Runs a dart program, expects it to exit with a given code, and returns
/// its [ProcessResult].
Future<ProcessResult> dartRun(
  List<String> args, {
  int expectedExitCode = 0,
  List<String> experiments = const [],
  String? workingDirectory,
}) async {
  final process = await Process.start(
    'dart',
    [
      if (experiments.isNotEmpty)
        '--enable-experiment=${experiments.join(',')}',
      'run',
      ...args,
    ],
    workingDirectory: workingDirectory,
  );

  final exitCode = await process.exitCode;
  final stderr = await process.stderr.toJointString();
  final stdout = await process.stdout.toJointString();

  expect(exitCode, expectedExitCode, reason: stderr);

  if (expectedExitCode == 0) {
    expect(
      stderr,
      '',
      reason: 'For the zero exit code, stderr is expected to be empty',
    );
  }

  return ProcessResult(
    exitCode: expectedExitCode,
    stderr: stderr,
    stdout: stdout,
  );
}

/// The result of a process run.
class ProcessResult {
  /// ignore: public_member_api_docs
  const ProcessResult({
    required this.exitCode,
    required this.stderr,
    required this.stdout,
  });

  /// ignore: public_member_api_docs
  final int exitCode;

  /// ignore: public_member_api_docs
  final String stderr;

  /// ignore: public_member_api_docs
  final String stdout;
}
