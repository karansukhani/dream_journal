import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth_cubit.dart';
import '../../utils/theme_helper.dart';
import '../auth/login_view.dart';
import '../home/home_view.dart'; // Adjust import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Define fade and scale animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Start animation
    _controller.forward();

    // Redirect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Trigger any auth check if needed
        context.read<AuthCubit>().checkAuthStatus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomeView();
        } else if (state is AuthUnauthenticated) {
          return const LoginView();
        }
        // Show splash screen while checking auth or during animation
        return Scaffold(
          backgroundColor: Colors.white, // Adjust as needed
          body: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nights_stay_rounded,
                      size: 80,
                      color: ThemeHelper.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dream Journal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}