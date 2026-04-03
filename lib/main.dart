import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owasptoprisks/dependencies.dart';
import 'package:owasptoprisks/dependencies_scope.dart';
import 'package:owasptoprisks/owasp_m1.dart';

void main() => runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();

  await $initization(
    proccess: (final double percent) {},
    onInitializationDone: (dependencies) {
      // OwaspM1();
      runApp(DependenciesScope.inject(dependencies, OwaspM1()));
    },
    onError: (step) {
      //
    },
  );
}, (error, stackTrace) {});

Future<void> $initization({
  required final void Function(double percent) proccess,
  required final void Function(Dependencies dependencies) onInitializationDone,
  required final void Function(int step) onError,
}) async {
  final dependencies = await $dependenciesInitialization(proccess, onError);
  onInitializationDone.call(dependencies);
}

Future<Dependencies> $dependenciesInitialization(
  void Function(double percent) proccess,
  void Function(int step) onError,
) async {
  final dependencies = Dependencies();
  final steps = _steps.entries;
  final stepsLength = steps.length;
  var stepCount = 0;
  for (final step in steps) {
    try {
      stepCount++;
      await step.value.call(dependencies);
      proccess.call(stepsLength / stepCount);
    } catch (error, stackTrace) {
      onError(stepCount);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
  return dependencies;
}

Map<String, FutureOr<void> Function(Dependencies dependencies)> get _steps {
  return {
    'flutter_secure_storage_initialization': (dependencies) {
      return dependencies.flutterSecureStorage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
          keyCipherAlgorithm: KeyCipherAlgorithm.AES_GCM_NoPadding,
        ),
        iOptions: IOSOptions(
          /// most relyable
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
    },
  };
}
