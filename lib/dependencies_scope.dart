import 'package:flutter/widgets.dart';

/// {@template dependencies_scope}
/// DependenciesScope widget.
/// {@endtemplate}
class DependenciesScope extends InheritedWidget {
  /// {@macro dependencies_scope}
  const DependenciesScope({
    required super.child,
    super.key, // ignore: unused_element_parameter
  });


  @override
  bool updateShouldNotify(covariant DependenciesScope oldWidget) => false;
}
