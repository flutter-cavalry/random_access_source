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

  test('ReadInto', () async {
    final src = await _bytesSource();
    final buffer = Uint8List(4);

    var bytesRead = await src.readInto(buffer, 0, 2);
    expect(bytesRead, 2);
    expect(buffer.sublist(0, 2), Uint8List.fromList([1, 2]));
    expect(await src.position(), 2);

    bytesRead = await src.readInto(buffer, 2, 2);
    expect(bytesRead, 2);
    expect(buffer.sublist(2, 4), Uint8List.fromList([3, 4]));
    expect(await src.position(), 4);

    bytesRead = await src.readInto(buffer, 0, 4);
    expect(bytesRead, 1);
    expect(buffer.sublist(0, 1), Uint8List.fromList([5]));
    expect(await src.position(), 5);

    bytesRead = await src.readInto(buffer, 0, 4);
    expect(bytesRead, 0);
    expect(await src.position(), 5);
    await src.close();
  });

  test('Position', () async {
    final src = await _bytesSource();
    expect(await src.position(), 0);
    await src.seek(2);
    expect(await src.position(), 2);
    expect(await src.readByte(), 3);
    await src.close();
  });

  test('ReadToEnd', () async {
    final src = await _bytesSource();
    expect(await src.readToEnd(), Uint8List.fromList([1, 2, 3, 4, 5]));
    expect(await src.position(), 5);
    await src.close();
  });

  test('ReadToEnd (halfway)', () async {
    final src = await _bytesSource();
    await src.seek(2);
    expect(await src.readToEnd(), Uint8List.fromList([3, 4, 5]));
    expect(await src.position(), 5);
    await src.close();
  });

  test('Skip (less than available)', () async {
    final src = await _bytesSource();
    expect(await src.skip(2), 2);
    expect(await src.position(), 2);
    expect(await src.readByte(), 3);
    await src.close();
  });

  test('Skip (more than available)', () async {
    final src = await _bytesSource();
    expect(await src.skip(10), 5);
    expect(await src.position(), 5);
    expect(await src.readByte(), -1);
    await src.close();
  });

  test('Skip (exactly available)', () async {
    final src = await _bytesSource();
    expect(await src.skip(5), 5);
    expect(await src.position(), 5);
    expect(await src.readByte(), -1);
    await src.close();
  });
}
