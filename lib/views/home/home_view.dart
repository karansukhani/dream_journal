import 'package:dream_journal/router/routing_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_journal/cubits/auth_cubit.dart';
import 'package:dream_journal/cubits/dream_cubit.dart';
import 'package:dream_journal/utils/theme_helper.dart';
import 'package:dream_journal/views/dreams/add_dream_view.dart';
import 'package:dream_journal/views/dreams/dreams_view.dart';
import 'package:dream_journal/views/mood/mood_tracker_view.dart';
import 'package:dream_journal/views/profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const DreamsView(),
    const MoodTrackerView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    // Load dreams when the home view is initialized
    context.read<DreamCubit>().loadDreams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  addDreamScreenRoute
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Dreams',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
