import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dream_journal/cubits/mood_cubit.dart';
import 'package:dream_journal/models/mood_model.dart';
import 'package:dream_journal/utils/theme_helper.dart';

class AddMoodView extends StatefulWidget {
  const AddMoodView({super.key});

  @override
  State<AddMoodView> createState() => _AddMoodViewState();
}

class _AddMoodViewState extends State<AddMoodView> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  
  MoodLevel _selectedMoodLevel = MoodLevel.neutral;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _saveMood() {
    if (_formKey.currentState!.validate()) {
      context.read<MoodCubit>().addMood(
        level: _selectedMoodLevel,
        note: _noteController.text.trim(),
        date: _selectedDate,
      );
      
      Navigator.pop(context);
    }
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
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'How do you feel today?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MoodLevel.values.map((level) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMoodLevel = level;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedMoodLevel == level
                                  ? _getMoodColor(level).withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedMoodLevel == level
                                    ? _getMoodColor(level)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getMoodIcon(level),
                              color: _getMoodColor(level),
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getMoodText(level),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedMoodLevel == level
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('MMMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveMood,
                    child: const Text('Save Mood'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
