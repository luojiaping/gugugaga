import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/settings_screen.dart';
import 'services/alist_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final serverUrl = prefs.getString('server_url') ?? '';
  runApp(GuGuGaGaApp(serverUrl: serverUrl));
}

class GuGuGaGaApp extends StatefulWidget {
  final String serverUrl;
  const GuGuGaGaApp({super.key, required this.serverUrl});

  @override
  State<GuGuGaGaApp> createState() => _GuGuGaGaAppState();
}

class _GuGuGaGaAppState extends State<GuGuGaGaApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _serverUrl = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _serverUrl = widget.serverUrl;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString('server_url') ?? '';
      final darkMode = prefs.getBool('dark_mode');
      if (darkMode != null) {
        _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
      }
    });
  }

  void _updateServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
    setState(() => _serverUrl = url);
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    await prefs.setBool('dark_mode', _themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '咕咕嘎嘎',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(
              serverUrl: _serverUrl,
              onPlay: (url, title) => _navigateToPlayer(url, title),
            ),
            SettingsScreen(
              serverUrl: _serverUrl,
              onServerUrlChanged: _updateServerUrl,
              onThemeToggled: _toggleTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.movie), label: '影视'),
            NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
          ],
        ),
      ),
    );
  }

  void _navigateToPlayer(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(url: url, title: title)),
    );
  }
}
