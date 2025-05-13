import 'package:dream_journal/services/supabase_service.dart';
import 'package:dream_journal/utils/theme_helper.dart';
import 'package:dream_journal/views/auth/login_view.dart';
import 'package:dream_journal/views/home/home_view.dart';
import 'package:dream_journal/views/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart' as router;
import 'constants/app_constants.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/dream_cubit.dart';
import 'cubits/mood_cubit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(supabaseService),
        ),
        BlocProvider<DreamCubit>(
          create: (context) => DreamCubit(supabaseService),
        ),
        BlocProvider<MoodCubit>(
          create: (context) => MoodCubit(supabaseService),
        ),
      ],
      child: MaterialApp(
        title: 'Dream Journal',
        theme: ThemeHelper.lightTheme,
        darkTheme: ThemeHelper.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: router.generateRoute,
        home: const SplashScreen()
      ),
    );
  }
}
