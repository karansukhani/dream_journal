import 'package:dream_journal/router/routing_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dream_journal/cubits/dream_cubit.dart';
import 'package:dream_journal/models/dream_model.dart';
import 'package:dream_journal/views/common/loading_indicator.dart';
import 'package:dream_journal/views/dreams/dream_detail_view.dart';

import '../../utils/theme_helper.dart';

class DreamsView extends StatefulWidget {
  const DreamsView({super.key});

  @override
  State<DreamsView> createState() => _DreamsViewState();
}

class _DreamsViewState extends State<DreamsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshDreams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshDreams() {
    context.read<DreamCubit>().loadDreams();
  }

  void _onDreamTap(Dream dream) {
    Navigator.pushNamed(
      context,
      dreamDetailScreenRoute,arguments: dream
    ).then((_) => _refreshDreams());
  }

  String _getClarityText(DreamClarity clarity) {
    switch (clarity) {
      case DreamClarity.veryVivid:
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDreams,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search dreams...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<DreamCubit, DreamState>(
              builder: (context, state) {
                if (state is DreamLoading) {
                  return const LoadingIndicator();
                } else if (state is DreamError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshDreams,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                } else if (state is DreamLoaded) {
                  final dreams = state.dreams;
                  
                  if (dreams.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.nights_stay_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No dreams recorded yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap + to add your first dream',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Filter dreams based on search query
                  final filteredDreams = _searchQuery.isEmpty
                      ? dreams
                      : dreams.where((dream) =>
                          dream.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          dream.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          dream.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
                  
                  if (filteredDreams.isEmpty) {
                    return const Center(
                      child: Text('No dreams match your search'),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshDreams();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDreams.length,
                      itemBuilder: (context, index) {
                        final dream = filteredDreams[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _onDreamTap(dream),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dream.imageUrl != null)
                                  Image.network(
                                    dream.imageUrl!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        height: 150,
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              dream.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getClarityColor(dream.clarity).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.visibility,
                                                  size: 14,
                                                  color: _getClarityColor(dream.clarity),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _getClarityText(dream.clarity),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _getClarityColor(dream.clarity),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        DateFormat('MMMM d, yyyy').format(dream.date),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dream.description,
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ThemeHelper.primaryColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getDreamTypeIcon(dream.type),
                                                  size: 14,
                                                  color: ThemeHelper.primaryColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  dream.type.toString().split('.').last,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: ThemeHelper.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: dream.tags.map((tag) {
                                                  return Container(
                                                    margin: const EdgeInsets.only(right: 8),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      '#$tag',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                
                // Initial state
                return const Center(
                  child: Text('Start recording your dreams'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
