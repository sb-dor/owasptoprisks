import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:l/l.dart';
import 'package:owasptoprisks/dependencies.dart';
import 'package:owasptoprisks/dependencies_scope.dart';
import 'package:owasptoprisks/owasp_m1.dart';
import 'error_widget.dart' deferred as error_widget;

void main() => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();

    await $initization(
      process: (final int percent) {
        l.d('initialization process is at $percent%');
      },
      onInitializationDone: (dependencies) {
        // OwaspM1();
        runApp(
          DependenciesScope.inject(dependencies, MaterialApp(home: OwaspM1())),
        );
      },
      onError: (step) async {
        await error_widget.loadLibrary();
        runApp(error_widget.ErrorWidget());
      },
    );
  },
  (error, stackTrace) {
    l.e(error, stackTrace);
  },
);

Future<void> $initization({
  required final void Function(int percent) process,
  required final void Function(Dependencies dependencies) onInitializationDone,
  required final void Function(int step) onError,
}) async {
  final dependencies = await $dependenciesInitialization(process, onError);
  onInitializationDone.call(dependencies);
}

Future<Dependencies> $dependenciesInitialization(
  void Function(int percent) process,
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
      process.call(stepsLength ~/ stepCount * 100);
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
        aOptions: AndroidOptions(),
        iOptions: IOSOptions(
          /// most relyable
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
    },
  };
}
