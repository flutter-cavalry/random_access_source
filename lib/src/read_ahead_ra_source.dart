import 'dart:math' as math;
import 'dart:typed_data';

import 'random_access_source.dart';

/// Coalesces small reads from another [RandomAccessSource].
///
/// The wrapped source must not be accessed directly and is closed by [close].
/// Its contents must remain unchanged while they are cached.
/// Operations on this stateful source must not overlap.
class ReadAheadRASource extends RandomAccessSource {
  /// Wraps [source] with a read-ahead buffer.
  ReadAheadRASource(RandomAccessSource source, {int bufferSize = 4096})
      : _source = source,
        _bufferSize = bufferSize {
    if (bufferSize <= 0) {
      throw RangeError.value(bufferSize, 'bufferSize', 'Must be positive');
    }
  }

  final RandomAccessSource _source;
  final int _bufferSize;

  Uint8List _buffer = Uint8List(0);
  int _bufferStart = 0;
  int? _position;
  bool _closed = false;

  @override
  Future<int> length() async {
    _checkOpen();
    return await _source.length();
  }

  @override
  Future<int> readByte() async {
    final bytes = await read(1);
    return bytes.isEmpty ? -1 : bytes[0];
  }

  @override
  Future<Uint8List> read(int count) async {
    _checkOpen();
    if (count < 0) {
      throw RangeError.value(count, 'count', 'Must not be negative');
    }
    if (count == 0) {
      return Uint8List(0);
    }

    final position = await _currentPosition();
    final bufferEnd = _bufferStart + _buffer.length;
    if (position < _bufferStart || position + count > bufferEnd) {
      await _source.seek(position);
      final buffer = await _source.read(math.max(_bufferSize, count));
      _buffer = buffer;
      _bufferStart = position;
    }

    final start = position - _bufferStart;
    final length = math.min(count, _buffer.length - start);
    if (length <= 0) {
      return Uint8List(0);
    }

    _position = position + length;
    return Uint8List.sublistView(_buffer, start, start + length);
  }

  @override
  Future<int> readInto(List<int> buffer, int offset, int count) async {
    _checkOpen();
    RangeError.checkValidRange(offset, offset + count, buffer.length);
    final position = await _currentPosition();
    final bytes = await read(count);
    try {
      buffer.setRange(offset, offset + bytes.length, bytes);
    } catch (_) {
      _position = position;
      rethrow;
    }
    return bytes.length;
  }

  @override
  Future<int> position() async {
    _checkOpen();
    return await _currentPosition();
  }

  @override
  Future<void> seek(int position) async {
    _checkOpen();
    if (position < 0) {
      throw RangeError.value(position, 'position', 'Must not be negative');
    }
    _position = position;
  }

  @override
  Future<Uint8List> readToEnd() async {
    _checkOpen();
    final position = await _currentPosition();
    await _source.seek(position);
    final bytes = await _source.readToEnd();
    _position = position + bytes.length;
    return bytes;
  }

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    _buffer = Uint8List(0);
    await _source.close();
  }

  Future<int> _currentPosition() async =>
      _position ??= await _source.position();

  void _checkOpen() {
    if (_closed) {
      throw StateError('Source is closed');
    }
  }
}
