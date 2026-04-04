import 'package:flutter/material.dart';

/// {@template error_widget}
/// ErrorWidget widget.
/// {@endtemplate}
class ErrorWidget extends StatefulWidget {
  /// {@macro error_widget}
  const ErrorWidget({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<ErrorWidget> createState() => _ErrorWidgetState();
}

/// State for widget ErrorWidget.
class _ErrorWidgetState extends State<ErrorWidget> {
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(body: Center(child: Text('App initialization went wrong'))),
  );
}
