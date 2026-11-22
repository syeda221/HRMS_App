import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/navigation/admin_navigation_shell.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/attendance/providers/attendance_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/navigation/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const HrmsStaffApp(),
    ),
  );
}

class HrmsStaffApp extends StatelessWidget {
  const HrmsStaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Widget getHomeScreen() {
      if (!auth.isAuthenticated) return const LoginScreen();
      if (auth.user?.isAdmin == true) return const AdminNavigationShell();
      return const MainNavigationShell();
    }

    return MaterialApp(
      title: 'QR Attendance Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: getHomeScreen(),
    );
  }
}
