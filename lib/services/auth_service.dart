import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart'; // Pastikan path ini benar

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _usersKey = 'registered_users';

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getRegisteredUsers();

      if (users.any((user) => user.email == email)) {
        return false;
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final newUser = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
      );

      users.add(newUser);
      await _saveRegisteredUsers(users);
      await prefs.setString('password_$email', _hashPassword(password));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getRegisteredUsers();
      final user = users.firstWhere((user) => user.email == email);

      final storedPassword = prefs.getString('password_$email');
      if (storedPassword == _hashPassword(password)) {
        await _saveCurrentUser(user);
        await prefs.setBool(_isLoggedInKey, true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return UserModel.fromJson(json.decode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> usersList = json.decode(usersJson);
      return usersList.map((user) => UserModel.fromJson(user)).toList();
    }
    return [];
  }

  Future<void> _saveRegisteredUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  Future<void> _saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
}