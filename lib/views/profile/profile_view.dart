import 'package:dream_journal/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_journal/cubits/auth_cubit.dart';
import 'package:dream_journal/cubits/dream_cubit.dart';
import 'package:dream_journal/cubits/mood_cubit.dart';
import 'package:dream_journal/utils/theme_helper.dart';
import 'package:dream_journal/views/common/loading_indicator.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pop(context);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthCubit, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingIndicator();
          } else if (state is AuthAuthenticated) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeHelper.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          ThemeHelper.primaryColor.withOpacity(0.2),
                      child: Text(
                        user.username?.substring(0, 1).toUpperCase() ??
                            user.email.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: ThemeHelper.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username ?? user.email,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _StatisticsSection(),
                  const SizedBox(height: 32),
                  const _SettingsSection(),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showSignOutConfirmation(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Please sign in'),
          );
        },
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<DreamCubit, DreamState>(
                    builder: (context, state) {
                      int dreamCount = 0;
                      if (state is DreamLoaded) {
                        dreamCount = state.dreams.length;
                      }

                      return _StatItem(
                        icon: Icons.nights_stay,
                        title: 'Dreams',
                        value: dreamCount.toString(),
                        color: ThemeHelper.primaryColor,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<MoodCubit, MoodState>(
                    builder: (context, state) {
                      int moodCount = 0;
                      if (state is MoodLoaded) {
                        moodCount = state.moods.length;
                      }

                      return _StatItem(
                        icon: Icons.mood,
                        title: 'Moods',
                        value: moodCount.toString(),
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                showSnackBarYellow(context, "Edit Profile - Coming Soon");
              },
            ),
            const Divider(),
            _SettingsItem(
              icon: Icons.color_lens_outlined,
              title: 'Theme',
              onTap: () {
                showSnackBarYellow(context, "Theme Settings - Coming Soon");
              },
            ),
            const Divider(),
            _SettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                showSnackBarYellow(context, 'Notifications - Coming Soon');
              },
            ),
            const Divider(),
            _SettingsItem(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              onTap: () {
                showSnackBarYellow(context, 'Privacy & Security - Coming Soon');
              },
            ),
            const Divider(),
            _SettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                showSnackBarYellow(context, 'Help & Support - Coming Soon');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: ThemeHelper.primaryColor),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
