import 'dart:typed_data';

import 'package:random_access_source/random_access_source.dart';
import 'package:test/test.dart';

Future<BytesRASource> _bytesSource() async {
  return BytesRASource(Uint8List.fromList([1, 2, 3, 4, 5]));
}

void main() {
  test('Length', () async {
    final src = await _bytesSource();
    expect(await src.length(), 5);
    await src.close();
  });

  test('ReadByte', () async {
    final src = await _bytesSource();
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
    final src = await _bytesSource();
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
    final src = await _bytesSource();
    expect(await src.position(), 0);
    await src.setPosition(2);
    expect(await src.position(), 2);
    expect(await src.readByte(), 3);
    await src.close();
  });
}
