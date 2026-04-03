import 'package:flutter/material.dart';

/// M1: Improper credential user

/// {@template owasp_m1}
/// OwaspM1 widget.
/// {@endtemplate}
class OwaspM1 extends StatefulWidget {
  /// {@macro owasp_m1}
  const OwaspM1({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<OwaspM1> createState() => _OwaspM1State();
}

/// State for widget OwaspM1.
class _OwaspM1State extends State<OwaspM1> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar());
}
