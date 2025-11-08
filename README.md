# random_access_source

[![pub package](https://img.shields.io/pub/v/random_access_source.svg)](https://pub.dev/packages/random_access_source)
[![Build Status](https://github.com/flutter-cavalry/random_access_source/workflows/Dart/badge.svg)](https://github.com/flutter-cavalry/random_access_source/actions)

A shared interface for common random access data.

## Usage

This library defines a common interface for random access data.

```dart
/// Base class for random access sources.
abstract class RandomAccessSource {
  /// Gets the length of the source.
  Future<int> length();

  /// Reads a byte from the source.
  Future<int> readByte();

  /// Reads an array of bytes from the source.
  Future<Uint8List> read(int count);

  /// Gets the current position in the source.
  Future<int> position();

  /// Sets the current position in the source.
  Future<void> seek(int position);

  /// Reads all the remaining bytes from the source.
  Future<Uint8List> readToEnd();

  /// Skips a number of bytes in the source.
  /// Returns the number of bytes actually skipped.
  Future<int> skip(int count);

  /// Reads a specific number of bytes, ensuring that the exact number is read.
  /// Throws an exception if the number of bytes read is not equal to [length].
  Future<Uint8List> mustRead(int length);

  /// Skips a specific number of bytes, ensuring that the exact number is skipped.
  /// Throws an exception if the number of bytes skipped is not equal to [length].
  Future<void> mustSkip(int length);

  /// Closes the source.
  Future<void> close();
}
```

Implementations:

- `BytesRASource` for `Uint8List`.
  - `BytesRASource(Uint8List bytes)`: creates a `BytesRASource` from the given `bytes`.
- `FileRASource` for `RandomAccessFile` (`dart:io`) and `Blob` (`package:web`).
  - `await FileRASource.open(path)`: Opens a `FileRASource` from a file path.
  - `await FileRASource.load(file)`: Loads a `FileRASource` from a `PlatformFile`.
