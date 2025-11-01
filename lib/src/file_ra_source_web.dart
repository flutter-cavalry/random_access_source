import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'bytes_ra_source.dart';
import 'file_ra_source.dart' as base;

typedef PlatformFile = web.Blob;

@JS('fetch')
external JSPromise<web.Response> _fetch(JSAny url);

class FileRASource extends base.FileRASource {
  final BytesRASource _bytes;

  FileRASource._(this._bytes);

  static Future<base.FileRASource> open(String path) async {
    final res = await _fetch(path.toJS).toDart;
    final bytes = (await res.bytes().toDart).toDart;
    return FileRASource._(BytesRASource(bytes));
  }

  static Future<FileRASource> load(PlatformFile file) async {
    final bytes = (await file.arrayBuffer().toDart).toDart.asUint8List();
    return FileRASource._(BytesRASource(bytes));
  }

  @override
  Future<int> length() => _bytes.length();

  @override
  Future<int> readByte() => _bytes.readByte();

  @override
  Future<Uint8List> read(int count) => _bytes.read(count);

  @override
  Future<int> position() => _bytes.position();

  @override
  Future<void> seek(int position) => _bytes.seek(position);

  @override
  Future<Uint8List> readToEnd() => _bytes.readToEnd();

  @override
  Future<void> close() => _bytes.close();
}
