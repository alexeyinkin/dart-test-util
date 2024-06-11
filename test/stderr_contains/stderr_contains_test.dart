import 'dart:io';

import 'package:test/test.dart';
import 'package:test_util/test_util.dart';

const _main = 'test/stderr_contains/example/main.dart';
const _lib = 'test/stderr_contains/example/lib.dart';

const _expectedErrors = [
  ExpectedFileErrors(_main, [
    ExpectedError("Type 'C' not found", [11]),
    ExpectedError("Setter not found: 'd'", [12]),
    ExpectedError("Field 'n' should be initialized because", [8, 4]),
  ]),
  ExpectedFileErrors(_lib, [
    ExpectedError('Variables must be declared using', [1]),
    ExpectedError('Undefined name', [1]),
    ExpectedError('should be initialized because', [1, 1]),
  ]),
];

const _wrongExpectedErrors = [
  ExpectedFileErrors(_main, [
    // Missing ("Type 'C' not found", [11]),
    ExpectedError("Setter not found: 'd'", [13]), // Actual: 12
    ExpectedError("Field 'n' should be", [8, 4, 9]), // Actual: [4, 8]
    ExpectedError('Non-existent error', [-3]), // Not exists.
  ]),
  ExpectedFileErrors(_lib, [
    ExpectedError('Variables must be declared using', [1]),
    ExpectedError('Undefined name', [1, 1]), // Actual: [1]
    ExpectedError('should be initialized because', [1]), // Actual: [1, 1]
  ]),
];

const _wrongExpectedErrorsDescription = '''
$_main: Setter not found: 'd'
  Expected lines: [13]
    Actual lines: [12]

$_main: Field 'n' should be
  Expected lines: [4, 8, 9]
    Actual lines: [4, 8]

$_main: Non-existent error
  Expected lines: [-3]
    Actual lines: []

$_lib: Undefined name
  Expected lines: [1, 1]
    Actual lines: [1]

$_lib: should be initialized because
  Expected lines: [1]
    Actual lines: [1, 1]

$_main: Extra errors:
11: Type 'C' not found.

''';

void main() async {
  final process = await Process.start('dart', ['run', _main]);

  await process.exitCode;
  final stderr = await process.stderr.toJointString();

  test('ok', () {
    expect(stderr, stderrContains(errors: _expectedErrors));
  });

  test('dartRun', () async {
    await dartRun(
      [_main],
      expectedExitCode: 254,
      expectedErrors: _expectedErrors,
    );
  });

  test('wrong', () {
    final matcher = stderrContains(errors: _wrongExpectedErrors);
    final mismatchDescription = StringDescription();
    final state = {};

    matcher.matches(stderr, state);
    matcher.describeMismatch(stderr, mismatchDescription, state, false);

    expect(
      mismatchDescription.toString(),
      _wrongExpectedErrorsDescription,
    );
  });
}
