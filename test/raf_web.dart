import 'package:random_access_source/random_access_source.dart';

Future<RandomAccessSource> rafSource() =>
    FileRASource.open('assets/flutter_icon_96x96.png');
