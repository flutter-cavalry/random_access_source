import 'dart:typed_data';

import 'package:random_access_source/random_access_source.dart';
import 'package:test/test.dart';

SyncBytesRASource _bytesSource() {
  return SyncBytesRASource(Uint8List.fromList([1, 2, 3, 4, 5]));
}

void main() {
  test('Length', () async {
    final src = _bytesSource();
    expect(src.length(), 5);
  });

  test('ReadByte', () async {
    final src = _bytesSource();
    expect(src.readByte(), 1);
    expect(src.position(), 1);

    expect(src.readByte(), 2);
    expect(src.position(), 2);

    expect(src.readByte(), 3);
    expect(src.position(), 3);

    expect(src.readByte(), 4);
    expect(src.position(), 4);

    expect(src.readByte(), 5);
    expect(src.position(), 5);

    expect(src.readByte(), -1);
    expect(src.position(), 5);
  });

  test('Read', () async {
    final src = _bytesSource();
    expect(src.read(2), Uint8List.fromList([1, 2]));
    expect(src.position(), 2);

    expect(src.read(2), Uint8List.fromList([3, 4]));
    expect(src.position(), 4);

    expect(src.read(2), Uint8List.fromList([5]));
    expect(src.position(), 5);

    expect(src.read(2), Uint8List(0));
    expect(src.position(), 5);
  });

  test('ReadInto', () async {
    final src = _bytesSource();
    final buffer = Uint8List(4);

    var bytesRead = src.readInto(buffer, 0, 2);
    expect(bytesRead, 2);
    expect(buffer.sublist(0, 2), Uint8List.fromList([1, 2]));
    expect(src.position(), 2);

    bytesRead = src.readInto(buffer, 2, 2);
    expect(bytesRead, 2);
    expect(buffer.sublist(2, 4), Uint8List.fromList([3, 4]));
    expect(src.position(), 4);

    bytesRead = src.readInto(buffer, 0, 4);
    expect(bytesRead, 1);
    expect(buffer.sublist(0, 1), Uint8List.fromList([5]));
    expect(src.position(), 5);

    bytesRead = src.readInto(buffer, 0, 4);
    expect(bytesRead, 0);
    expect(src.position(), 5);
  });

  test('Position', () async {
    final src = _bytesSource();
    expect(src.position(), 0);
    src.seek(2);
    expect(src.position(), 2);
    expect(src.readByte(), 3);
  });

  test('ReadToEnd', () async {
    final src = _bytesSource();
    expect(src.readToEnd(), Uint8List.fromList([1, 2, 3, 4, 5]));
    expect(src.position(), 5);
  });

  test('ReadToEnd (halfway)', () async {
    final src = _bytesSource();
    src.seek(2);
    expect(src.readToEnd(), Uint8List.fromList([3, 4, 5]));
    expect(src.position(), 5);
  });
}
