import 'package:flutter/widgets.dart';
import 'package:owasptoprisks/dependencies.dart';

/// {@template dependencies_scope}
/// DependenciesScope widget.
/// {@endtemplate}
class DependenciesScope extends InheritedWidget {
  /// {@macro dependencies_scope}
  const DependenciesScope({
    required this.dependencies,
    required super.child,
    super.key, // ignore: unused_element_parameter
  });

  static Widget inject(final Dependencies dependencies, final Widget child) =>
      DependenciesScope(dependencies: dependencies, child: child);

  final Dependencies dependencies;

  

  @override
  bool updateShouldNotify(covariant DependenciesScope oldWidget) => false;
}
