import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _backUrl = 'http://192.168.16.222:8000/api';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

enum UserRole {
  cashier,
  manager,
  admin;

  static UserRole byName(final String? name) {
    return values.firstWhereOrNull((el) => el.name == name) ?? UserRole.cashier;
  }
}

class User {
  User({required this.name, required this.email, required this.role, required this.token});

  factory User.fromJson(final Map<String, Object?> json, String token) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.byName(json['role'] as String),
      token: token,
    );
  }

  final String name;
  final String email;
  final UserRole role;
  final String token;
}

/// {@template owasp_m3}
/// OwaspM3 widget.
/// {@endtemplate}
class AppScope extends InheritedWidget {
  /// {@macro owasp_m3}
  const AppScope({
    required this.state,
    required super.child,
    super.key, // ignore: unused_element_parameter
  });

  static Apptate of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<AppScope>()?.widget;
    assert(widget != null, 'No AppScope was found in element tree');
    return (widget as AppScope).state;
  }

  final Apptate state;

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) => false;
}

/// {@template owasp_m3}
/// OwaspM3 widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro owasp_m3}
  const App({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<App> createState() => Apptate();
}

/// State for widget OwaspM3.
class Apptate extends State<App> {
  late User user;

  void initUser(final User user) {
    this.user = user;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => AppScope(
    state: this,
    child: MaterialApp(home: OwaspM3()),
  );
}

/// {@template owasp_m3}
/// OwaspM3 widget.
/// {@endtemplate}
class OwaspM3 extends StatefulWidget {
  /// {@macro owasp_m3}
  const OwaspM3({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<OwaspM3> createState() => _OwaspM3State();
}

/// State for widget OwaspM3.
class _OwaspM3State extends State<OwaspM3> {
  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    final response = await http.post(
      Uri.parse('$_backUrl/auth/login'),
      body: <String, Object?>{"email": _emailController.text.trim(), "password": _passwordController.text.trim()},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, Object?>;
      final userJson = json['user'] as Map<String, Object?>;
      final user = User.fromJson(userJson, json['access_token'] as String);
      if (mounted) {
        print(response.body);
        AppScope.of(context).initUser(user);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UsersScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Owasp m3')),
    body: CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: 'password'),
                ),
                ElevatedButton(onPressed: _signIn, child: Text("Sign in")),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// {@template owasp_m3}
/// UsersScreen widget.
/// {@endtemplate}
class UsersScreen extends StatefulWidget {
  /// {@macro owasp_m3}
  const UsersScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

/// State for widget UsersScreen.
class _UsersScreenState extends State<UsersScreen> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    _loadUsers();
  }

  void _loadUsers() async {
    final user = AppScope.of(context).user;
    final response = await http.get(
      Uri.parse('$_backUrl/admin/users'),
      headers: <String, String>{'Authorization': 'Bearer ${user.token}'},
    );
    print(response.body);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Users')),
    body: Center(child: Text("All users")),
  );
}
