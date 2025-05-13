import 'package:dream_journal/router/routing_constants.dart';
import 'package:dream_journal/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dream_journal/cubits/dream_cubit.dart';
import 'package:dream_journal/models/dream_model.dart';
import 'package:dream_journal/utils/theme_helper.dart';
import 'package:dream_journal/views/dreams/edit_dream_view.dart';

class DreamDetailView extends StatelessWidget {
  final Dream dream;
  
  const DreamDetailView({
    super.key,
    required this.dream,
  });
  
  String _getClarityText(DreamClarity clarity) {
    switch (clarity) {
      case DreamClarity.veryVivid:
        return 'Very Vivid';
      case DreamClarity.vivid:
        return 'Very Vivid';
      case DreamClarity.vivid:
        return 'Vivid';
      case DreamClarity.moderate:
        return 'Moderate';
      case DreamClarity.vague:
        return 'Vague';
      case DreamClarity.veryVague:
        return 'Very Vague';
    }
  }

  Color _getClarityColor(DreamClarity clarity) {
    switch (clarity) {
      case DreamClarity.veryVivid:
        return Colors.purple;
      case DreamClarity.vivid:
        return Colors.deepPurple;
      case DreamClarity.moderate:
        return Colors.blue;
      case DreamClarity.vague:
        return Colors.lightBlue;
      case DreamClarity.veryVague:
        return Colors.blueGrey;
    }
  }

  IconData _getDreamTypeIcon(DreamType type) {
    switch (type) {
      case DreamType.lucid:
        return Icons.lightbulb;
      case DreamType.nightmare:
        return Icons.warning;
      case DreamType.recurring:
        return Icons.repeat;
      case DreamType.normal:
        return Icons.cloud;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dream'),
        content: const Text('Are you sure you want to delete this dream? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DreamCubit>().deleteDream(dream.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dreams list
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
        title: const Text('Dream Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                editDreamScreenRoute,arguments: dream
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: BlocListener<DreamCubit, DreamState>(
        listener: (context, state) {
          if (state is DreamError) {
           showSnackBarRed(context, state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dream.imageUrl != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(dream.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                dream.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM d, yyyy').format(dream.date),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getClarityColor(dream.clarity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: _getClarityColor(dream.clarity),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getClarityText(dream.clarity),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getClarityColor(dream.clarity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeHelper.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDreamTypeIcon(dream.type),
                          size: 16,
                          color: ThemeHelper.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dream.type.toString().split('.').last,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dream.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: dream.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Created: ${DateFormat('MMM d, yyyy').format(dream.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (dream.updatedAt != dream.createdAt)
                Text(
                  'Last edited: ${DateFormat('MMM d, yyyy').format(dream.updatedAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
