import 'dart:typed_data';

import '../random_access_source.dart';

/// A class that reads binary data from a [RandomAccessSource].
class RandomAccessBinaryReader {
  final RandomAccessSource source;
  Endian endian = Endian.big;

  RandomAccessBinaryReader(this.source);

  Future<Uint8List> readBytes(int count) async {
    return source.read(count);
  }

  Future<Uint8List> mustReadBytes(int count) async {
    final data = await source.read(count);
    if (data.length != count) {
      throw Exception(
          'Unexpected end of file, expected $count bytes, but got ${data.length} bytes');
    }
    return data;
  }

  Future<double> readFloat32([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(4);
    return ByteData.sublistView(data).getFloat32(0, ed);
  }

  Future<double> readFloat64([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(8);
    return ByteData.sublistView(data).getFloat64(0, ed);
  }

  Future<int> readInt8() async {
    final data = await mustReadBytes(1);
    return ByteData.sublistView(data).getInt8(0);
  }

  Future<int> readInt16([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(2);
    return ByteData.sublistView(data).getInt16(0, ed);
  }

  Future<int> readInt32([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(4);
    return ByteData.sublistView(data).getInt32(0, ed);
  }

  Future<int> readInt64([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(8);
    return ByteData.sublistView(data).getInt64(0, ed);
  }

  Future<int> readUint8() async {
    final data = await mustReadBytes(1);
    return ByteData.sublistView(data).getUint8(0);
  }

  Future<int> readUint16([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(2);
    return ByteData.sublistView(data).getUint16(0, ed);
  }

  Future<int> readUint32([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(4);
    return ByteData.sublistView(data).getUint32(0, ed);
  }

  Future<int> readUint64([Endian? endian]) async {
    final ed = endian ?? this.endian;
    final data = await mustReadBytes(8);
    return ByteData.sublistView(data).getUint64(0, ed);
  }
}
