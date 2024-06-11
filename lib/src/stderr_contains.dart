import 'package:collection/collection.dart';
import 'package:test/test.dart';

/// ignore: public_member_api_docs
class ExpectedFileErrors {
  /// ignore: public_member_api_docs
  final String fileName;

  /// ignore: public_member_api_docs
  final List<ExpectedError> errors;

  /// ignore: public_member_api_docs
  const ExpectedFileErrors(this.fileName, this.errors);
}

/// ignore: public_member_api_docs
class ExpectedError {
  /// ignore: public_member_api_docs
  final String contains;

  /// ignore: public_member_api_docs
  final List<int> lineNumbers;

  /// ignore: public_member_api_docs
  const ExpectedError(this.contains, this.lineNumbers);
}

class _ActualError {
  final String fileName;
  final String message;
  final int lineNumber;

  const _ActualError({
    required this.fileName,
    required this.message,
    required this.lineNumber,
  });
}

/// Matches the stderr output of a Dart program that contains [errors].
Matcher stderrContains({
  List<ExpectedFileErrors> errors = const [],
}) =>
    _StderrContains(errors: errors);

const _mismatchKey = 'mismatch';

class _StderrContains extends Matcher {
  final List<ExpectedFileErrors> errors;

  _StderrContains({
    required this.errors,
  });

  @override
  Description describe(Description description) {
    return description
        .add('stderr contains specified compile errors at given line numbers');
  }

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! String) {
      return false;
    }

    bool ok = true;
    final lines = item.split('\n');
    final foundErrors = <String, Map<int, _ActualError>>{};
    int key = 0;

    for (final line in lines) {
      final match = RegExp(r'^(.*):(\d+):\d+: Error: (.*)').firstMatch(line);
      if (match != null) {
        final fileName = match.group(1)!;
        final lineNumber = int.parse(match.group(2)!);
        final message = match.group(3)!;

        foundErrors[fileName] ??= {};
        foundErrors[fileName]![key++] = _ActualError(
          fileName: fileName,
          message: message,
          lineNumber: lineNumber,
        );
      }
    }

    final mismatches = <_Mismatch>[];

    for (final expectedFile in errors) {
      final fileName = expectedFile.fileName;
      final foundFileErrors = foundErrors[fileName] ?? {};

      for (final expectedError in expectedFile.errors) {
        final actualLineNumbers = <int>[];

        for (final entry in [...foundFileErrors.entries]) {
          final actualError = entry.value;
          if (actualError.message.contains(expectedError.contains)) {
            actualLineNumbers.add(actualError.lineNumber);
            foundFileErrors.remove(entry.key);
          }
        }

        final expectedSorted = [...expectedError.lineNumbers]..sort();
        actualLineNumbers.sort();

        if (!const ListEquality().equals(expectedSorted, actualLineNumbers)) {
          mismatches.add(
            _LineNumbersMismatch(
              fileName: fileName,
              error: expectedError,
              expectedLineNumbers: expectedSorted,
              actualLineNumbers: actualLineNumbers,
            ),
          );
          ok = false;
        }
      }
    }

    for (final entry in foundErrors.entries) {
      final errors = entry.value.values;
      if (errors.isNotEmpty) {
        mismatches.add(
          _ExtraErrorsMismatch(
            fileName: entry.key,
            errors: errors.toList(growable: false),
          ),
        );
        ok = false;
      }
    }

    matchState[_mismatchKey] = mismatches;
    return ok;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    final mismatches = matchState[_mismatchKey] as List<_Mismatch>?;

    if (mismatches == null) {
      return mismatchDescription.add('was $item');
    }

    for (final mismatch in mismatches) {
      // ignore: parameter_assignments
      mismatchDescription = mismatch.describe(mismatchDescription);
    }

    return mismatchDescription;
  }
}

abstract class _Mismatch {
  const _Mismatch();

  Description describe(Description description);
}

class _LineNumbersMismatch extends _Mismatch {
  final String fileName;
  final ExpectedError error;
  final List<int> expectedLineNumbers;
  final List<int> actualLineNumbers;

  const _LineNumbersMismatch({
    required this.fileName,
    required this.error,
    required this.expectedLineNumbers,
    required this.actualLineNumbers,
  });

  @override
  Description describe(Description description) {
    // TODO(alexeyinkin): Diff.
    return description.add(
      '$fileName: ${error.contains}\n'
      '  Expected lines: $expectedLineNumbers\n'
      '    Actual lines: $actualLineNumbers\n\n',
    );
  }
}

class _ExtraErrorsMismatch extends _Mismatch {
  final String fileName;
  final List<_ActualError> errors;

  const _ExtraErrorsMismatch({
    required this.fileName,
    required this.errors,
  });

  @override
  Description describe(Description description) {
    return description.add(
      '$fileName: Extra errors:\n'
      '${errors.map((e) => '${e.lineNumber}: ${e.message}\n').join()}'
      '\n',
    );
  }
}
