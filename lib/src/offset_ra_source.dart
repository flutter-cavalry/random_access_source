import 'dart:typed_data';

import 'random_access_source.dart';

/// Exposes a [RandomAccessSource] starting at [positionOffset].
///
/// The wrapped source is closed by [close] and must not be accessed directly.
class OffsetRASource extends RandomAccessSource {
  /// Creates a view of [source] whose position zero is [positionOffset].
  OffsetRASource(RandomAccessSource source, {required int positionOffset})
      : _source = source,
        positionOffset = positionOffset {
    if (positionOffset <= 0) {
      throw RangeError.value(
        positionOffset,
        'positionOffset',
        'Must be positive',
      );
    }
  }

  final RandomAccessSource _source;

  /// The position in the wrapped source that is exposed as position zero.
  final int positionOffset;

  @override
  Future<int> length() async {
    final sourceLength = await _source.length();
    return (sourceLength - positionOffset).clamp(0, sourceLength);
  }

  @override
  Future<int> readByte() => _source.readByte();

  @override
  Future<Uint8List> read(int count) => _source.read(count);

  @override
  Future<int> readInto(List<int> buffer, int offset, int count) =>
      _source.readInto(buffer, offset, count);

  @override
  Future<int> position() async => await _source.position() - positionOffset;

  @override
  Future<void> seek(int position) async {
    if (position < 0) {
      throw RangeError.value(position, 'position', 'Must not be negative');
    }
    await _source.seek(positionOffset + position);
  }

  @override
  Future<Uint8List> readToEnd() => _source.readToEnd();

  @override
  Future<void> close() => _source.close();
}
