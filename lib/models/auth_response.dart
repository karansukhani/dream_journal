import 'package:dream_journal/models/user_model.dart';

class AuthenticationResponse {
  final bool isSuccess;
  final String? message;
  final UserData? data;

  AuthenticationResponse({required this.isSuccess, this.message,  this.data});
}
