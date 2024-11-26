import 'dart:io';
import 'dart:typed_data';

import 'package:random_access_source/random_access_source.dart';
import 'package:test/test.dart';
import 'package:tmp_path/tmp_path.dart';

String? _tmpFile;

Future<RandomAccessSource> _rafSource() async {
  if (_tmpFile == null) {
    final tmp = tmpPath();
    await File(tmp).writeAsBytes([1, 2, 3, 4, 5]);
    _tmpFile = tmp;
  }
  return FileRASource.open(_tmpFile!);
}

void main() {
  test('Length', () async {
    final src = await _rafSource();
    expect(await src.length(), 5);
    await src.close();
  });

  test('ReadByte', () async {
    final src = await _rafSource();
    expect(await src.readByte(), 1);
    expect(await src.position(), 1);

    expect(await src.readByte(), 2);
    expect(await src.position(), 2);

    expect(await src.readByte(), 3);
    expect(await src.position(), 3);

    expect(await src.readByte(), 4);
    expect(await src.position(), 4);

    expect(await src.readByte(), 5);
    expect(await src.position(), 5);

    expect(await src.readByte(), -1);
    expect(await src.position(), 5);
    await src.close();
  });

  test('Read', () async {
    final src = await _rafSource();
    expect(await src.read(2), Uint8List.fromList([1, 2]));
    expect(await src.position(), 2);

    expect(await src.read(2), Uint8List.fromList([3, 4]));
    expect(await src.position(), 4);

    expect(await src.read(2), Uint8List.fromList([5]));
    expect(await src.position(), 5);

    expect(await src.read(2), Uint8List(0));
    expect(await src.position(), 5);
    await src.close();
  });

  test('Position', () async {
    final src = await _rafSource();
    expect(await src.position(), 0);
    await src.setPosition(2);
    expect(await src.position(), 2);
    expect(await src.readByte(), 3);
    await src.close();
  });

  test('ReadToEnd', () async {
    final src = await _rafSource();
    expect(await src.readToEnd(), Uint8List.fromList([1, 2, 3, 4, 5]));
    expect(await src.position(), 5);
    await src.close();
  });

  test('ReadToEnd (halfway)', () async {
    final src = await _rafSource();
    await src.setPosition(2);
    expect(await src.readToEnd(), Uint8List.fromList([3, 4, 5]));
    expect(await src.position(), 5);
    await src.close();
  });
}
