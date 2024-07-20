// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:random_access_source/random_access_source.dart';

void main() async {
  final source = BytesRASource(Uint8List.fromList([1, 2, 3, 4, 5]));
  print(await source.length());
  print(await source.readByte());
  print(await source.read(2));
  print(await source.position());
  await source.close();
}
