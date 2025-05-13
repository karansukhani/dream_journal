import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:dream_journal/models/dream_model.dart';
import 'package:dream_journal/services/supabase_service.dart';

// States
abstract class DreamState {}

class DreamInitial extends DreamState {}

class DreamLoading extends DreamState {}

class DreamLoaded extends DreamState {
  final List<Dream> dreams;
  DreamLoaded(this.dreams);
}

class DreamError extends DreamState {
  final String message;
  DreamError(this.message);
}

// Cubit
class DreamCubit extends Cubit<DreamState> {
  final SupabaseService _supabaseService;
  final _uuid = const Uuid();

  DreamCubit(this._supabaseService) : super(DreamInitial());

  Future<void> loadDreams() async {
    emit(DreamLoading());
    
    try {
      final dreams = await _supabaseService.getDreams();
      emit(DreamLoaded(dreams));
    } catch (e) {
      emit(DreamError('Failed to load dreams. Please try again.'));
    }
  }

  Future<void> addDream({
    required String title,
    required String description,
    required DateTime date,
    required List<String> tags,
    required DreamClarity clarity,
    required DreamType type,
    int? moodId,
    File? image,
  }) async {
    emit(DreamLoading());
    
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        emit(DreamError('User not authenticated'));
        return;
      }

      String? imageUrl;
      if (image != null) {
        imageUrl = await _supabaseService.uploadDreamImage(image);
      }

      final now = DateTime.now();
      final dream = Dream(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        description: description,
        date: date,
        tags: tags,
        clarity: clarity,
        type: type,
        moodId: moodId,
        imageUrl: imageUrl,
        createdAt: now,
        updatedAt: now,
      );

      final success = await _supabaseService.addDream(dream);
      
      if (success) {
        await loadDreams();
      } else {
        emit(DreamError('Failed to add dream. Please try again.'));
      }
    } catch (e) {
      emit(DreamError('An error occurred. Please try again.'));
    }
  }

  Future<void> updateDream({
    required String id,
    String? title,
    String? description,
    DateTime? date,
    List<String>? tags,
    DreamClarity? clarity,
    DreamType? type,
    int? moodId,
    File? image,
  }) async {
    emit(DreamLoading());
    
    try {
      final currentDream = await _supabaseService.getDream(id);
      
      if (currentDream == null) {
        emit(DreamError('Dream not found'));
        return;
      }

      String? imageUrl = currentDream.imageUrl;
      if (image != null) {
        imageUrl = await _supabaseService.uploadDreamImage(image);
      }

      final updatedDream = currentDream.copyWith(
        title: title,
        description: description,
        date: date,
        tags: tags,
        clarity: clarity,
        type: type,
        moodId: moodId,
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      final success = await _supabaseService.updateDream(updatedDream);
      
      if (success) {
        await loadDreams();
      } else {
        emit(DreamError('Failed to update dream. Please try again.'));
      }
    } catch (e) {
      emit(DreamError('An error occurred. Please try again.'));
    }
  }

  Future<void> deleteDream(String id) async {
    emit(DreamLoading());
    
    try {
      final success = await _supabaseService.deleteDream(id);
      
      if (success) {
        await loadDreams();
      } else {
        emit(DreamError('Failed to delete dream. Please try again.'));
      }
    } catch (e) {
      emit(DreamError('An error occurred. Please try again.'));
    }
  }
}
