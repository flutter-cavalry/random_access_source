import 'dart:typed_data';

import 'file_ra_source.dart' as base;

typedef PlatformFile = Object;

abstract class FileRASource extends base.FileRASource {
  static Future<FileRASource> open(String path) =>
      throw UnsupportedError('Not supported on this platform.');

  static Future<FileRASource> load(PlatformFile file) =>
      throw UnsupportedError('Not supported on this platform.');

  @override
  Future<int> length() =>
      throw UnsupportedError('Not supported on this platform.');

  @override
  Future<int> readByte() =>
      throw UnsupportedError('Not supported on this platform.');

  @override
  Future<Uint8List> read(int count) =>
      throw UnsupportedError('Not supported on this platform.');

  @override
  Future<int> position() =>
      throw UnsupportedError('Not supported on this platform.');

  @override
  Future<void> seek(int position) =>
      throw UnsupportedError('Not supported on this platform.');

  @override
  Future<Uint8List> readToEnd() =>
      throw UnsupportedError('Not supported on this platform.');

  @override
  Future<void> close() =>
      throw UnsupportedError('Not supported on this platform.');
}
