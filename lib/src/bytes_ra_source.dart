import 'dart:typed_data';

import '../random_access_source.dart';

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
    final result = Uint8List.sublistView(_bytes, _position, end);
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
  Future<Uint8List> readToEnd() async {
    final result = Uint8List.sublistView(_bytes, _position);
    _position = _bytes.length;
    return result;
  }

  @override
  Future<void> close() async {}
}
