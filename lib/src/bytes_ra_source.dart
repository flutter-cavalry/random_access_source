import 'dart:typed_data';

import '../random_access_source.dart';

class BytesRASource extends RandomAccessSource {
  late final SyncBytesRASource _syncSource;

  Uint8List get bytes => _syncSource._bytes;

  /// Creates a [BytesRASource] from the given [bytes].
  BytesRASource(Uint8List bytes) {
    _syncSource = SyncBytesRASource(bytes);
  }

  @override
  Future<int> length() async => bytes.length;

  @override
  Future<int> readByte() async => _syncSource.readByte();

  @override
  Future<Uint8List> read(int count) async => _syncSource.read(count);

  @override
  Future<int> position() async => _syncSource.position();

  @override
  Future<void> seek(int position) async => _syncSource.seek(position);

  @override
  Future<Uint8List> readToEnd() async => _syncSource.readToEnd();

  @override
  Future<void> close() async {}
}

class SyncBytesRASource {
  final Uint8List _bytes;
  int _position = 0;

  SyncBytesRASource(this._bytes);

  int length() {
    return _bytes.length;
  }

  int readByte() {
    if (_position >= _bytes.length) {
      return -1;
    }
    return _bytes[_position++];
  }

  Uint8List read(int length) {
    if (_position >= _bytes.length) {
      return Uint8List(0);
    }
    final end = (_position + length).clamp(0, _bytes.length);
    final result = Uint8List.sublistView(_bytes, _position, end);
    _position = end;
    return result;
  }

  int position() {
    return _position;
  }

  void seek(int position) {
    _position = position;
  }

  Uint8List readToEnd() {
    final result = Uint8List.sublistView(_bytes, _position);
    _position = _bytes.length;
    return result;
  }
}
