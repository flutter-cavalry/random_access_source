import 'dart:typed_data';

import 'package:test/test.dart';

import 'assets/flutter_icon_96x96.dart';
import 'raf_vm.dart' if (dart.library.js_interop) 'raf_web.dart';

void main() {
  test('Length', () async {
    final src = await rafSource();
    expect(await src.length(), flutterIcon.length);
    await src.close();
  });

  test('ReadByte', () async {
    final src = await rafSource();
    expect(await src.readByte(), flutterIcon[0]);
    expect(await src.position(), 1);

    expect(await src.readByte(), flutterIcon[1]);
    expect(await src.position(), 2);

    expect(await src.readByte(), flutterIcon[2]);
    expect(await src.position(), 3);

    expect(await src.readByte(), flutterIcon[3]);
    expect(await src.position(), 4);

    expect(await src.readByte(), flutterIcon[4]);
    expect(await src.position(), 5);

    expect(await src.readByte(), flutterIcon[5]);
    expect(await src.position(), 6);
    await src.close();
  });

  test('Read', () async {
    final src = await rafSource();
    expect(await src.read(2), flutterIcon.sublist(0, 2));
    expect(await src.position(), 2);

    expect(await src.read(2), flutterIcon.sublist(2, 4));
    expect(await src.position(), 4);

    await src.close();
  });

  test('ReadInto', () async {
    final src = await rafSource();
    final buffer = Uint8List(4);

    var bytesRead = await src.readInto(buffer, 0, 2);
    expect(bytesRead, 2);
    expect(buffer.sublist(0, 2), flutterIcon.sublist(0, 2));
    expect(await src.position(), 2);

    bytesRead = await src.readInto(buffer, 2, 2);
    expect(bytesRead, 2);
    expect(buffer.sublist(2, 4), flutterIcon.sublist(2, 4));
    expect(await src.position(), 4);

    await src.close();
  });

  test('Position', () async {
    final src = await rafSource();
    expect(await src.position(), 0);
    await src.seek(2);
    expect(await src.position(), 2);
    expect(await src.readByte(), flutterIcon[2]);
    await src.close();
  });

  test('ReadToEnd', () async {
    final src = await rafSource();
    expect(await src.readToEnd(), flutterIcon);
    expect(await src.position(), flutterIcon.length);
    await src.close();
  });

  test('ReadToEnd (halfway)', () async {
    final src = await rafSource();
    await src.seek(2);
    expect(await src.readToEnd(), flutterIcon.sublist(2));
    expect(await src.position(), flutterIcon.length);
    await src.close();
  });

  test('Skip (less than available)', () async {
    final src = await rafSource();
    expect(await src.skip(2), 2);
    expect(await src.position(), 2);
    expect(await src.readByte(), flutterIcon[2]);
    await src.close();
  });

  test('Skip (more than available)', () async {
    final src = await rafSource();
    expect(await src.skip(flutterIcon.length * 2), flutterIcon.length);
    expect(await src.position(), flutterIcon.length);
    expect(await src.readByte(), -1);
    await src.close();
  });

  test('Skip (exactly available)', () async {
    final src = await rafSource();
    expect(await src.skip(flutterIcon.length), flutterIcon.length);
    expect(await src.position(), flutterIcon.length);
    expect(await src.readByte(), -1);
    await src.close();
  });
}
