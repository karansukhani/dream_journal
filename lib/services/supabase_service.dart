import 'dart:io';
import 'package:dream_journal/models/auth_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:dream_journal/constants/app_constants.dart';
import 'package:dream_journal/models/dream_model.dart';
import 'package:dream_journal/models/mood_model.dart';
import 'package:dream_journal/models/user_model.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;
  final _uuid = const Uuid();

  // Auth methods
  Future<UserData?> getCurrentUser() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from(AppConstants.usersCollection)
          .select()
          .eq('id', userId)
          .single();

      return UserData.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<AuthenticationResponse> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final now = DateTime.now();

        // Check if a user with this id already exists in the users table
        final existingUserResponse = await client
            .from(AppConstants.usersCollection)
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (existingUserResponse != null) {
          print("User with id $userId already exists in users table");
          // User already exists in the users table; consider this a success
          return AuthenticationResponse(isSuccess: true);
        }

        // If user doesn't exist, proceed with the insert
        try {
          print(
              "Attempting to insert into table: ${AppConstants.usersCollection}");
          final insertResponse =
              await client.from(AppConstants.usersCollection).insert({
            'id': userId,
            'email': email,
            'created_at': now.toIso8601String(),
          }).select();

          if (insertResponse == null || insertResponse.isEmpty) {
            print("Database insert failed");
            return AuthenticationResponse(
                isSuccess: false,
                message:
                    "Database insert failed: No response from the server.");
          }

          print("Insert successful");
          return AuthenticationResponse(isSuccess: true);
        } catch (dbError) {
          print("Database insert error: $dbError");
          return AuthenticationResponse(
              isSuccess: false, message: "Database insert error: $dbError");
        }
      }

      print("Sign-up failed: No user created");
      return AuthenticationResponse(
          isSuccess: false, message: "Sign-up failed: No user created");
    } catch (e) {
      print("Sign-up error: $e");
      return AuthenticationResponse(
          isSuccess: false, message: "Sign-up error: $e");
    }
  }

  Future<AuthenticationResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        await client.from(AppConstants.usersCollection).update(
            {'last_login': DateTime.now().toIso8601String()}).eq('id', user.id);

        return AuthenticationResponse(
            isSuccess: true,
            data: UserData(
                id: response.user?.id ?? '',
                email: email,
                createdAt: DateTime.tryParse(response.user?.createdAt ?? '') ??
                    DateTime.now(),
                lastLogin:
                    DateTime.tryParse(response.user?.lastSignInAt ?? '') ??
                        DateTime.now()));
      }

      return AuthenticationResponse(
          isSuccess: false, message: 'Sign in failed.');
    } on AuthApiException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email_not_confirmed':
          errorMessage = 'Email not confirmed. Please verify your email.';
          break;
        case 'invalid_credentials':
          errorMessage = 'Invalid email or password. Please try again.';
          break;
        case 'user_not_found':
          errorMessage = 'No user found with the given email.';
          break;
        default:
          errorMessage = 'Authentication error: ${e.message}';
      }

      return AuthenticationResponse(isSuccess: false, message: errorMessage);
    } catch (e) {
      print('Sign in error: $e');
      return AuthenticationResponse(
          isSuccess: false, message: 'An unexpected error occurred.');
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Dreams methods
  Future<List<Dream>> getDreams() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await client
          .from(AppConstants.dreamsCollection)
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return response.map((dream) => Dream.fromJson(dream)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Dream?> getDream(String id) async {
    try {
      final response = await client
          .from(AppConstants.dreamsCollection)
          .select()
          .eq('id', id)
          .single();

      return Dream.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addDream(Dream dream) async {
    try {
      await client.from(AppConstants.dreamsCollection).insert(dream.toJson());
      return true;
    } on PostgrestException catch (e) {
      print('Database Error: ${e.message}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      return false;
    } catch (e) {
      print('Unexpected Error: $e');
      return false;
    }
  }

  Future<bool> updateDream(Dream dream) async {
    try {
      await client
          .from(AppConstants.dreamsCollection)
          .update(dream.toJson())
          .eq('id', dream.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDream(String id) async {
    try {
      await client.from(AppConstants.dreamsCollection).delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadDreamImage(File imageFile) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final extension = imageFile.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final filePath = '$userId/$fileName';

      await client.storage
          .from(AppConstants.dreamImagesStorage)
          .upload(filePath, imageFile);

      return client.storage
          .from(AppConstants.dreamImagesStorage)
          .getPublicUrl(filePath);
    } catch (e) {
      return null;
    }
  }

  // Mood methods
  Future<List<Mood>> getMoods() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await client
          .from(AppConstants.moodsCollection)
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return response.map((mood) => Mood.fromJson(mood)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Mood?> getMood(int id) async {
    try {
      final response = await client
          .from(AppConstants.moodsCollection)
          .select()
          .eq('id', id)
          .single();

      return Mood.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addMood(Mood mood) async {
    try {
      final response = await client
          .from(AppConstants.moodsCollection)
          .insert(mood.toJson())
          .select()
          .maybeSingle();

      if (response == null) {
        print('Insert operation succeeded but no data was returned.');
        return false;
      }

      print('Mood inserted successfully: $response');
      return true;
    } on PostgrestException catch (e) {
      print('Database Error: ${e.message}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      return false;
    } catch (e) {
      print('Unexpected Error: $e');
      return false;
    }
  }

  Future<bool> updateMood(Mood mood) async {
    try {
      await client
          .from(AppConstants.moodsCollection)
          .update(mood.toJson())
          .eq('id', mood.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMood(int id) async {
    try {
      await client.from(AppConstants.moodsCollection).delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
