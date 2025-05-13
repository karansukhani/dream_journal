import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dream_journal/cubits/mood_cubit.dart';
import 'package:dream_journal/models/mood_model.dart';
import 'package:dream_journal/utils/theme_helper.dart';
import 'package:dream_journal/views/common/loading_indicator.dart';
import 'package:dream_journal/views/mood/add_mood_view.dart';
import 'package:dream_journal/views/mood/mood_chart_view.dart';

class MoodTrackerView extends StatefulWidget {
  const MoodTrackerView({super.key});

  @override
  State<MoodTrackerView> createState() => _MoodTrackerViewState();
}

class _MoodTrackerViewState extends State<MoodTrackerView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<MoodCubit>().loadMoods();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _refreshMoods() {
    context.read<MoodCubit>().loadMoods();
  }
  
  void _showAddMoodBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddMoodView(),
    ).then((_) => _refreshMoods());
  }
  
  IconData _getMoodIcon(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryHappy:
        return Icons.sentiment_very_satisfied;
      case MoodLevel.happy:
        return Icons.sentiment_satisfied;
      case MoodLevel.neutral:
        return Icons.sentiment_neutral;
      case MoodLevel.sad:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.verySad:
        return Icons.sentiment_very_dissatisfied;
    }
  }
  
  Color _getMoodColor(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryHappy:
        return Colors.green;
      case MoodLevel.happy:
        return Colors.lightGreen;
      case MoodLevel.neutral:
        return Colors.blue;
      case MoodLevel.sad:
        return Colors.orange;
      case MoodLevel.verySad:
        return Colors.red;
    }
  }
  
  String _getMoodText(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryHappy:
        return 'Very Happy';
      case MoodLevel.happy:
        return 'Happy';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.sad:
        return 'Sad';
      case MoodLevel.verySad:
        return 'Very Sad';
    }
  }
  
  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mood'),
        content: const Text('Are you sure you want to delete this mood record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MoodCubit>().deleteMood(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMoods,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List'),
            Tab(text: 'Chart'),
          ],
        ),
      ),
      body: BlocBuilder<MoodCubit, MoodState>(
        builder: (context, state) {
          if (state is MoodLoading) {
            return const LoadingIndicator();
          } else if (state is MoodError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshMoods,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is MoodLoaded) {
            final moods = state.moods;
            
            if (moods.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mood_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No mood records yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap + to add your first mood record',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _showAddMoodBottomSheet,
                      child: const Text('Add Mood'),
                    ),
                  ],
                ),
              );
            }
            
            return TabBarView(
              controller: _tabController,
              children: [
                // List View
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    final mood = moods[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      child: Dismissible(
                        key: Key(mood.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          context.read<MoodCubit>().deleteMood(mood.id);
                        },
                        confirmDismiss: (_) async {
                          bool delete = false;
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Mood'),
                              content: const Text('Are you sure you want to delete this mood record?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    delete = false;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    delete = true;
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          return delete;
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getMoodColor(mood.level).withOpacity(0.2),
                            child: Icon(
                              _getMoodIcon(mood.level),
                              color: _getMoodColor(mood.level),
                            ),
                          ),
                          title: Text(
                            _getMoodText(mood.level),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMMM d, yyyy').format(mood.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (mood.note != null && mood.note!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    mood.note!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _showDeleteConfirmation(context, mood.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Chart View
                MoodChartView(moods: moods),
              ],
            );
          }
          
          // Initial state
          return const Center(
            child: Text('Start tracking your mood'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMoodBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
