import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Base class for random access sources.
abstract class RandomAccessSource {
  /// Gets the length of the source.
  Future<int> length();

  /// Reads a byte from the source.
  Future<int> readByte();

  /// Reads an array of bytes from the source.
  Future<Uint8List> read(int count);

  /// Reads bytes into the provided buffer.
  Future<int> readInto(List<int> buffer, int offset, int count);

  /// Gets the current position in the source.
  Future<int> position();

  /// Sets the current position without checking whether [position] is valid.
  ///
  /// Do not call this directly; use [trySeek] or [mustSeek].
  @protected
  Future<void> seekCore(int position);

  /// Returns whether [position] is outside the source boundaries.
  Future<bool> _isSeekPositionOOR(int position) async {
    final sourceLength = await length();
    return position < 0 || position > sourceLength;
  }

  /// Attempts to seek to [position], returning false if it cannot be reached.
  /// This method never throws.
  Future<bool> trySeek(int position) async {
    try {
      if (await _isSeekPositionOOR(position)) {
        return false;
      }
      await seekCore(position);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Seeks to [position], throwing if it is out of range or the seek fails.
  Future<void> mustSeek(int position) async {
    if (await _isSeekPositionOOR(position)) {
      throw RangeError.value(position, 'position');
    }
    await seekCore(position);
  }

  /// Reads all the remaining bytes from the source.
  Future<Uint8List> readToEnd();

  /// Skips a number of bytes in the source.
  /// Returns the number of bytes actually skipped.
  Future<int> skip(int count) async {
    final currentPosition = await position();
    final fileLength = await length();

    // Calculate the target position clamped within the file boundaries
    final targetPosition = (currentPosition + count).clamp(0, fileLength);
    await mustSeek(targetPosition);

    // Calculate the actual bytes skipped
    final actualSkipped = targetPosition - currentPosition;
    return actualSkipped;
  }

  /// Reads a specific number of bytes, ensuring that the exact number is read.
  /// Throws an exception if the number of bytes read is not equal to [length].
  Future<Uint8List> mustRead(int length, {String? errorTag}) async {
    final bytes = await read(length);
    if (bytes.length != length) {
      throw Exception(
          '${errorTag != null ? '$errorTag: ' : ''}Failed to read $length bytes, got ${bytes.length}');
    }
    return bytes;
  }

  /// Skips a specific number of bytes, ensuring that the exact number is skipped.
  /// Throws an exception if the number of bytes skipped is not equal to [length].
  Future<void> mustSkip(int length) async {
    final count = await skip(length);
    if (count != length) {
      throw Exception('Failed to skip $length bytes, skipped $count bytes');
    }
  }

  /// Closes the source.
  Future<void> close();

  /// Restores the position after executing the given [action].
  Future<T> restorePosition<T>(Future<T> Function() action) async {
    final currentPosition = await position();
    try {
      return await action();
    } finally {
      await mustSeek(currentPosition);
    }
  }
}
