import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_journal/models/mood_model.dart';
import 'package:dream_journal/services/supabase_service.dart';

// States
abstract class MoodState {}

class MoodInitial extends MoodState {}

class MoodLoading extends MoodState {}

class MoodLoaded extends MoodState {
  final List<Mood> moods;
  MoodLoaded(this.moods);
}

class MoodError extends MoodState {
  final String message;
  MoodError(this.message);
}

// Cubit
class MoodCubit extends Cubit<MoodState> {
  final SupabaseService supabaseService;

  MoodCubit(this.supabaseService) : super(MoodInitial());

  Future<void> loadMoods() async {
    emit(MoodLoading());
    
    try {
      final moods = await supabaseService.getMoods();
      emit(MoodLoaded(moods));
    } catch (e) {
      emit(MoodError('Failed to load moods. Please try again.'));
    }
  }

  Future<void> addMood({
    required MoodLevel level,
    String? note,
    required DateTime date,
  }) async {
    emit(MoodLoading());
    
    try {
      final userId = supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        emit(MoodError('User not authenticated'));
        return;
      }

      final now = DateTime.now();
      final mood = Mood(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        level: level,
        note: note,
        date: date,
        createdAt: now,
      );

      final success = await supabaseService.addMood(mood);
      
      if (success) {
        await loadMoods();
      } else {
        emit(MoodError('Failed to add mood. Please try again.'));
      }
    } catch (e) {
      emit(MoodError('An error occurred. Please try again.'));
    }
  }

  Future<void> updateMood({
    required int id,
    MoodLevel? level,
    String? note,
    DateTime? date,
  }) async {
    emit(MoodLoading());
    
    try {
      final currentMood = await supabaseService.getMood(id);
      
      if (currentMood == null) {
        emit(MoodError('Mood not found'));
        return;
      }

      final updatedMood = currentMood.copyWith(
        level: level,
        note: note,
        date: date,
      );

      final success = await supabaseService.updateMood(updatedMood);
      
      if (success) {
        await loadMoods();
      } else {
        emit(MoodError('Failed to update mood. Please try again.'));
      }
    } catch (e) {
      emit(MoodError('An error occurred. Please try again.'));
    }
  }

  Future<void> deleteMood(int id) async {
    emit(MoodLoading());
    
    try {
      final success = await supabaseService.deleteMood(id);
      
      if (success) {
        await loadMoods();
      } else {
        emit(MoodError('Failed to delete mood. Please try again.'));
      }
    } catch (e) {
      emit(MoodError('An error occurred. Please try again.'));
    }
  }
}
