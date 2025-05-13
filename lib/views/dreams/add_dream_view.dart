import 'dart:io';
import 'package:dream_journal/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dream_journal/cubits/dream_cubit.dart';
import 'package:dream_journal/models/dream_model.dart';
import 'package:dream_journal/utils/theme_helper.dart';
import 'package:dream_journal/views/common/loading_indicator.dart';

class AddDreamView extends StatefulWidget {
  const AddDreamView({super.key});

  @override
  State<AddDreamView> createState() => _AddDreamViewState();
}

class _AddDreamViewState extends State<AddDreamView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  DreamClarity _selectedClarity = DreamClarity.moderate;
  DreamType _selectedType = DreamType.normal;
  final List<String> _tags = [];
  final _tagController = TextEditingController();
  
  File? _selectedImage;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
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
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }
  
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  void _saveDream() {
    if (_formKey.currentState!.validate()) {
      context.read<DreamCubit>().addDream(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        tags: _tags,
        clarity: _selectedClarity,
        type: _selectedType,
        image: _selectedImage,
      );
      
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Dream'),
      ),
      body: BlocListener<DreamCubit, DreamState>(
        listener: (context, state) {
          if (state is DreamError) {
            showSnackBarRed(context, state.message);
          }
        },
        child: BlocBuilder<DreamCubit, DreamState>(
          builder: (context, state) {
            if (state is DreamLoading) {
              return const LoadingIndicator();
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add an image (optional)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            : Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Dream Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                    DropdownButtonFormField<DreamClarity>(
                      value: _selectedClarity,
                      decoration: const InputDecoration(
                        labelText: 'Dream Clarity',
                        prefixIcon: Icon(Icons.visibility),
                      ),
                      items: DreamClarity.values.map((clarity) {
                        return DropdownMenuItem<DreamClarity>(
                          value: clarity,
                          child: Text(_getClarityText(clarity)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedClarity = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DreamType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Dream Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: DreamType.values.map((type) {
                        return DropdownMenuItem<DreamType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Dream Description',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: 'Add Tags',
                              prefixIcon: Icon(Icons.tag),
                            ),
                            onFieldSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                          color: ThemeHelper.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDream,
                        child: const Text('Save Dream'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
}
