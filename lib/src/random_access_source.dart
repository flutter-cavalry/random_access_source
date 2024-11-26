import 'dart:typed_data';

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

  /// Reads all the remaining bytes from the source.
  Future<Uint8List> readToEnd();

  /// Closes the source.
  Future<void> close();
}
