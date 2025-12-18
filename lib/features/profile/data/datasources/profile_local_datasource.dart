import 'dart:convert';

import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel?> getProfile(String userId);
  Future<void> saveProfile(ProfileModel profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _profileKeyPrefix = 'user_profile_';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  String _getKey(String userId) => '$_profileKeyPrefix$userId';

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    final jsonString = sharedPreferences.getString(_getKey(userId));
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return ProfileModel.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    final jsonString = json.encode(profile.toJson());
    await sharedPreferences.setString(_getKey(profile.userId), jsonString);
  }
}
