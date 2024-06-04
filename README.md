Various helpers and utilities for testing.

# Usage

```dart
import 'package:test/test.dart';
import 'package:test_util/test_util.dart';

void main() {
  test('A dart program succeeds', () async {
    await dartPubGet();
    final result = await dartRun(
      ['hello.dart', 'Alexey'],
      workingDirectory: 'example',
    );

    expect(result.stdout, 'Hello, Alexey!\n');
  });

  test('A dart program fails', () async {
    await dartPubGet();
    final result = await dartRun(
      ['fail.dart'],
      expectedExitCode: 123,
      workingDirectory: 'example',
    );

    expect(result.stderr, 'My error.\n');
  });
}
```
