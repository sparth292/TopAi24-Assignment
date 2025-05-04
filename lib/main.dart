import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'splash_screen.dart';
import 'delete_data_page.dart';
import 'logout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  print('Supabase initialized!');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          background: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.blue),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.blue),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const EntryPoint(),
    );
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});
  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _loading = true;
  firebase_auth.User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    setState(() { _loading = true; });
    _user = firebase_auth.FirebaseAuth.instance.currentUser;
    setState(() { _loading = false; });
  }

  void _onLoginSuccess() async {
    setState(() { _loading = true; });
    _user = firebase_auth.FirebaseAuth.instance.currentUser;
    setState(() { _loading = false; });
  }

  void _onLogout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    setState(() { _user = null; });
  }

  void _onDelete() async {
    final email = _user?.email;
    if (email != null) {
      await Supabase.instance.client.from('users').delete().eq('email', email);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SplashScreen();
    if (_user == null) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }
    return HomeScreen(
      user: _user!,
      onLogout: _onLogout,
      onDelete: _onDelete,
    );
  }
}
