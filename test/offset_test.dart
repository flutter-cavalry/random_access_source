import 'dart:typed_data';

import 'package:random_access_source/random_access_source.dart';
import 'package:test/test.dart';

void main() {
  test('Exposes the source from the configured offset', () async {
    final source = BytesRASource(Uint8List.fromList([0, 1, 2, 3, 4]));
    await source.mustSeek(2);
    final offset = OffsetRASource(source, positionOffset: 2);

    expect(await offset.length(), 3);
    expect(await offset.position(), 0);
    expect(await offset.read(2), [2, 3]);
    expect(await offset.position(), 2);
    expect(await source.position(), 4);
  });

  test('Translates seeks to positions in the wrapped source', () async {
    final source = BytesRASource(Uint8List.fromList([0, 1, 2, 3, 4]));
    final offset = OffsetRASource(source, positionOffset: 2);

    await offset.mustSeek(1);
    expect(await source.position(), 3);
    expect(await offset.position(), 1);
    expect(await offset.readToEnd(), [3, 4]);
  });

  test('Requires a positive position offset', () {
    for (final positionOffset in [0, -1]) {
      expect(
        () => OffsetRASource(
          BytesRASource(Uint8List(1)),
          positionOffset: positionOffset,
        ),
        throwsRangeError,
      );
    }
  });

  test('Rejects negative logical positions', () async {
    final source = BytesRASource(Uint8List(2));
    await source.mustSeek(1);
    final offset = OffsetRASource(source, positionOffset: 1);

    await expectLater(offset.mustSeek(-1), throwsRangeError);
    expect(await offset.position(), 0);
  });

  test('Allows seeking to EOF but rejects positions past it', () async {
    final source = BytesRASource(Uint8List(4));
    final offset = OffsetRASource(source, positionOffset: 1);

    await offset.mustSeek(3);
    expect(await source.position(), 4);
    await expectLater(offset.mustSeek(4), throwsRangeError);
    expect(await offset.position(), 3);
  });
}
