import 'dart:math' as math;
import 'dart:typed_data';

import 'package:random_access_source/random_access_source.dart';
import 'package:test/test.dart';

void main() {
  test('Coalesces reads and seeks within the buffer', () async {
    final source = _TrackingSource(_bytes(12));
    final buffered = ReadAheadRASource(source, bufferSize: 4);

    expect(await buffered.readByte(), 0);
    expect(await buffered.read(2), [1, 2]);
    await buffered.seek(1);
    expect(await buffered.read(2), [1, 2]);
    expect(source.reads, [4]);
    expect(source.seeks, [0]);

    expect(await buffered.read(2), [3, 4]);
    expect(source.reads, [4, 4]);
    expect(source.seeks, [0, 3]);
  });

  test('Uses the requested size when it exceeds the buffer', () async {
    final source = _TrackingSource(_bytes(12));
    final buffered = ReadAheadRASource(source, bufferSize: 4);

    expect(await buffered.read(6), [0, 1, 2, 3, 4, 5]);
    expect(source.reads, [6]);
  });

  test('Starts at the wrapped source position', () async {
    final source = _TrackingSource(_bytes(6));
    await source.seek(2);
    source.seeks.clear();

    final buffered = ReadAheadRASource(source, bufferSize: 2);
    expect(await buffered.read(2), [2, 3]);
    expect(await buffered.position(), 4);
    expect(source.seeks, [2]);
  });

  test('A seek before the first read overrides the wrapped position', () async {
    final source = _TrackingSource(_bytes(6));
    await source.seek(2);
    final buffered = ReadAheadRASource(source, bufferSize: 2);

    await buffered.seek(4);
    expect(await buffered.readByte(), 4);
  });

  test('Handles EOF and readToEnd', () async {
    final source = _TrackingSource(_bytes(5));
    final buffered = ReadAheadRASource(source, bufferSize: 4);

    await buffered.seek(2);
    expect(await buffered.readToEnd(), [2, 3, 4]);
    expect(await buffered.position(), 5);
    expect(await buffered.readByte(), -1);
    expect(await buffered.position(), 5);
  });

  test('Handles buffer boundaries and positions past EOF', () async {
    final source = _TrackingSource(_bytes(5));
    final buffered = ReadAheadRASource(source, bufferSize: 4);

    expect(await buffered.read(4), [0, 1, 2, 3]);
    expect(await buffered.readByte(), 4);
    expect(await buffered.readByte(), -1);
    await buffered.seek(8);
    expect(await buffered.readByte(), -1);
    expect(await buffered.position(), 8);
  });

  test('Advances by the bytes returned from a short read', () async {
    final source = _TrackingSource(_bytes(6), maxRead: 2);
    final buffered = ReadAheadRASource(source, bufferSize: 4);

    expect(await buffered.read(4), [0, 1]);
    expect(await buffered.position(), 2);
    expect(await buffered.read(4), [2, 3]);
    expect(await buffered.position(), 4);
  });

  test('Keeps position and cache when a refill fails', () async {
    final source = _TrackingSource(_bytes(8));
    final buffered = ReadAheadRASource(source, bufferSize: 4);

    expect(await buffered.read(2), [0, 1]);
    await buffered.seek(6);
    source.failNextRead = true;
    await expectLater(buffered.readByte(), throwsStateError);
    expect(await buffered.position(), 6);

    await buffered.seek(1);
    expect(await buffered.readByte(), 1);
    await buffered.seek(6);
    expect(await buffered.readByte(), 6);
    expect(source.reads, [4, 4]);
  });

  test('Validates arguments without changing position', () async {
    final source = _TrackingSource(_bytes(4));
    final buffered = ReadAheadRASource(source);

    await expectLater(buffered.read(-1), throwsRangeError);
    await expectLater(buffered.seek(-1), throwsRangeError);
    for (final arguments in [(-1, 1), (0, -1), (1, 2)]) {
      await expectLater(
        buffered.readInto(Uint8List(2), arguments.$1, arguments.$2),
        throwsRangeError,
      );
    }
    expect(await buffered.read(0), isEmpty);
    expect(await buffered.position(), 0);
    expect(source.reads, isEmpty);
  });

  test('Reads into a range and stops at EOF', () async {
    final source = _TrackingSource(_bytes(4));
    final buffered = ReadAheadRASource(source);
    final destination = Uint8List.fromList([9, 9, 9, 9]);

    await buffered.seek(3);
    expect(await buffered.readInto(destination, 1, 3), 1);
    expect(destination, [9, 3, 9, 9]);
    expect(await buffered.position(), 4);
  });

  test('Restores position when the destination rejects a write', () async {
    final source = _TrackingSource(_bytes(4));
    final buffered = ReadAheadRASource(source);
    final destination = List<int>.unmodifiable([0]);

    await expectLater(
      buffered.readInto(destination, 0, 1),
      throwsUnsupportedError,
    );
    expect(await buffered.position(), 0);
    expect(await buffered.readByte(), 0);
    expect(source.reads, [4096]);
  });

  test('Closes the wrapped source', () async {
    final source = _TrackingSource(_bytes(2));
    final buffered = ReadAheadRASource(source);

    await buffered.close();
    await buffered.close();
    expect(source.closeCalls, 1);

    final operations = <Future<void> Function()>[
      () async {
        await buffered.length();
      },
      () async {
        await buffered.readByte();
      },
      () async {
        await buffered.read(0);
      },
      () async {
        await buffered.readInto(Uint8List(0), 0, 0);
      },
      () async {
        await buffered.position();
      },
      () async {
        await buffered.seek(0);
      },
      () async {
        await buffered.readToEnd();
      },
    ];
    for (final operation in operations) {
      await expectLater(operation(), throwsStateError);
    }
  });

  test('Requires a positive buffer size', () {
    for (final size in [0, -1]) {
      expect(
        () => ReadAheadRASource(_TrackingSource(_bytes(1)), bufferSize: size),
        throwsRangeError,
      );
    }
  });

  test('Keeps returned bytes valid after a refill', () async {
    final source = _TrackingSource(_bytes(6));
    final buffered = ReadAheadRASource(source, bufferSize: 2);

    final first = await buffered.read(2);
    expect(await buffered.read(2), [2, 3]);
    expect(first, [0, 1]);
  });
}

Uint8List _bytes(int length) =>
    Uint8List.fromList(List<int>.generate(length, (index) => index));

class _TrackingSource extends RandomAccessSource {
  _TrackingSource(Uint8List bytes, {this.maxRead})
      : _source = BytesRASource(bytes);

  final BytesRASource _source;
  final int? maxRead;
  final List<int> reads = [];
  final List<int> seeks = [];
  bool failNextRead = false;
  int closeCalls = 0;

  @override
  Future<void> close() async {
    closeCalls++;
    await _source.close();
  }

  @override
  Future<int> length() => _source.length();

  @override
  Future<int> position() => _source.position();

  @override
  Future<Uint8List> read(int count) async {
    if (failNextRead) {
      failNextRead = false;
      throw StateError('Read failed');
    }
    reads.add(count);
    return _source.read(maxRead == null ? count : math.min(count, maxRead!));
  }

  @override
  Future<int> readByte() => _source.readByte();

  @override
  Future<int> readInto(List<int> buffer, int offset, int count) =>
      _source.readInto(buffer, offset, count);

  @override
  Future<Uint8List> readToEnd() => _source.readToEnd();

  @override
  Future<void> seek(int position) async {
    seeks.add(position);
    await _source.seek(position);
  }
}
