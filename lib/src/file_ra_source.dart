import '../random_access_source.dart';
import 'file_ra_source_stub.dart'
    if (dart.library.io) 'file_ra_source_vm.dart'
    if (dart.library.js_interop) 'file_ra_source_web.dart' as impl;

typedef PlatformFile = impl.PlatformFile;

abstract class FileRASource extends RandomAccessSource {
  /// Opens a [FileRASource] from a file path.
  static Future<FileRASource> open(String path) => impl.FileRASource.open(path);

  /// Loads a [FileRASource] from a [PlatformFile].
  static Future<FileRASource> load(PlatformFile file) =>
      impl.FileRASource.load(file);
}
