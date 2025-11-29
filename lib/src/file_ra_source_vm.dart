import 'dart:io' as io;
import 'dart:typed_data';

import 'file_ra_source.dart' as base;

typedef PlatformFile = io.File;

class FileRASource extends base.FileRASource {
  final io.RandomAccessFile _file;

  FileRASource._(this._file);

  static Future<FileRASource> openPath(String path) async =>
      FileRASource._(await io.File(path).open());

  static Future<FileRASource> loadFile(PlatformFile file) async =>
      FileRASource._(await file.open());

  @override
  Future<int> length() => _file.length();

  @override
  Future<int> readByte() => _file.readByte();

  @override
  Future<Uint8List> read(int count) => _file.read(count);

  @override
  Future<int> position() => _file.position();

  @override
  Future<void> seek(int position) => _file.setPosition(position);

  @override
  Future<Uint8List> readToEnd() async => _file.read(await _file.length());

  @override
  Future<void> close() => _file.close();
}
