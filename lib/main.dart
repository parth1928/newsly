import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'view/login_view.dart';
import 'view/register_view.dart';
import 'view/pages/explorer_page.dart';
import 'view/pages/profile_page.dart';
import 'view/pages/saved_news_page.dart';
import 'view/pages/swipe_news_screen.dart';
import 'view/pages/home_page.dart';
import 'view/verify_email_view.dart';
import 'constants/style_constants.dart';
import 'services/firebase_service.dart';
import 'widgets/floating_nav_bar.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    print('Flutter binding initialized');

    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Initialize test data
    print('Starting test data initialization...');
    final firebaseService = FirebaseService();

    try {
      await firebaseService.addTestData();
      print('Test data initialized successfully');

      // Verify data was added by fetching articles
      final articles = await firebaseService.fetchNewsArticles();
      print('Verification: Found ${articles.length} articles in database');
    } catch (e) {
      print('Error during test data initialization: $e');
      // Continue with app initialization even if test data fails
    }
  } catch (e) {
    print('Error during app initialization: $e');
    // Handle initialization error gracefully
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Newsly',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentSecondary,
          surface: AppColors.surface,
          onPrimary: AppColors.background,
          onSecondary: AppColors.background,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.heading1,
          displayMedium: AppTypography.heading2,
          displaySmall: AppTypography.heading3,
          bodyLarge: AppTypography.body1,
          bodyMedium: AppTypography.body2,
          labelSmall: AppTypography.caption,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtonStyle.primaryButton,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.divider),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/verify-email': (context) => const VerifyEmailView(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'An error occurred',
                style: AppTypography.body1
                    .copyWith(color: AppColors.actionPrimary),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // Initialize user data in Firestore
          final firebaseService = FirebaseService();
          firebaseService.initializeUserData(user).then((_) {
            print('User data initialized for ${user.email}');
          }).catchError((error) {
            print('Error initializing user data: $error');
          });

          // For Google Sign-In users, skip email verification
          if (user.providerData
              .any((userInfo) => userInfo.providerId == 'google.com')) {
            return const MainScreen();
          }
          // For email/password users, check verification
          if (!user.emailVerified) {
            return const VerifyEmailView();
          }
          return const MainScreen();
        }

        return const LoginView();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SwipeNewsScreen(),
    ExplorerPage(),
    SavedNewsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: _pages[_selectedIndex]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              selectedIndex: _selectedIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
