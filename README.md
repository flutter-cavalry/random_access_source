# random_access_source

Shared interfaces for random access data

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
  Future<Uint8List> read(int length);

  /// Gets the current position in the source.
  Future<int> position();

  /// Sets the current position in the source.
  Future<void> setPosition(int position);

  /// Closes the source.
  Future<void> close();
}
```

Implementations:

- `BytesRASource` for `Uint8List` data
- `RandomAccessFileRASource` for `RandomAccessFile` data
