import 'dart:io';
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

  /// Closes the source.
  Future<void> close();
}

class BytesRASource extends RandomAccessSource {
  final Uint8List _bytes;
  int _position = 0;

  BytesRASource(this._bytes);

  @override
  Future<int> length() async {
    return _bytes.length;
  }

  @override
  Future<int> readByte() async {
    if (_position >= _bytes.length) {
      return -1;
    }
    return _bytes[_position++];
  }

  @override
  Future<Uint8List> read(int length) async {
    if (_position >= _bytes.length) {
      return Uint8List(0);
    }
    final end = (_position + length).clamp(0, _bytes.length);
    final result = _bytes.sublist(_position, end);
    _position = end;
    return result;
  }

  @override
  Future<int> position() async {
    return _position;
  }

  @override
  Future<void> setPosition(int position) async {
    _position = position;
  }

  @override
  Future<void> close() async {}
}

class RandomAccessFileRASource extends RandomAccessSource {
  final RandomAccessFile _file;

  RandomAccessFileRASource(this._file);

  static Future<RandomAccessFileRASource> open(String path) async {
    final file = await File(path).open();
    return RandomAccessFileRASource(file);
  }

  @override
  Future<int> length() async {
    return _file.length();
  }

  @override
  Future<int> readByte() async {
    return _file.readByte();
  }

  @override
  Future<Uint8List> read(int length) async {
    return _file.read(length);
  }

  @override
  Future<int> position() async {
    return _file.position();
  }

  @override
  Future<void> setPosition(int position) async {
    await _file.setPosition(position);
  }

  @override
  Future<void> close() async {
    await _file.close();
  }
}
