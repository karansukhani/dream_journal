import 'package:dream_journal/models/dream_model.dart';
import 'package:dream_journal/router/routing_constants.dart';
import 'package:dream_journal/views/auth/signup_view.dart';
import 'package:dream_journal/views/dreams/add_dream_view.dart';
import 'package:dream_journal/views/dreams/dream_detail_view.dart';
import 'package:dream_journal/views/dreams/edit_dream_view.dart';
import 'package:flutter/material.dart';

import '../views/splash_screen/splash_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashScreenRoute:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case signupScreenRoute:
      return MaterialPageRoute(builder: (_) => const SignUpView());
    case editDreamScreenRoute:
      return MaterialPageRoute(
          builder: (_) => EditDreamView(dream: settings.arguments as Dream));
    case addDreamScreenRoute:
      return MaterialPageRoute(builder: (_) => const AddDreamView());
    case dreamDetailScreenRoute:
      return MaterialPageRoute(
          builder: (_) => DreamDetailView(
                dream: settings.arguments as Dream,
              ));
    default:
      return MaterialPageRoute(builder: (_) {
        return Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        );
      });
  }
}
