import 'dart:io';
import 'dart:typed_data';

import '../random_access_source.dart';

class FileRASource extends RandomAccessSource {
  final RandomAccessFile _file;

  FileRASource(this._file);

  static Future<FileRASource> open(String path) async {
    final file = await File(path).open();
    return FileRASource(file);
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
  Future<Uint8List> readToEnd() async {
    return _file.read(await _file.length());
  }

  @override
  Future<void> close() async {
    await _file.close();
  }
}
