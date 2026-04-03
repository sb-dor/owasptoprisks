import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Dependencies {
  late final FlutterSecureStorage flutterSecureStorage;
}

@visibleForTesting
class FakeDependencies extends Dependencies {}
