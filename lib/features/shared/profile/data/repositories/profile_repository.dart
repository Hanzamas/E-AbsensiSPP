import '../models/basic_user_info.dart';
import '../services/profile_services.dart';
import 'dart:io';

class ProfileRepository {
  final ProfileServices _service = ProfileServices();

  Future<BasicUserInfo?> getUserInfo() async {
    final data = await _service.getUserInfo();
    return BasicUserInfo.fromJson(data);
  }

  Future<BasicUserInfo?> updateUserInfo({
    required String username,
    required String email,
    String? profilePict,
  }) async {
    final data = await _service.updateUserInfo(
      username: username,
      email: email,
      profilePict: profilePict,
    );
    return BasicUserInfo.fromJson(data);
  }

  Future<String> uploadProfilePicture(File file) async {
    return await _service.uploadProfilePicture(file);
  }

  Future<String> replaceProfilePicture(String oldFileName, File newFile) async {
    return await _service.replaceProfilePicture(oldFileName, newFile);
  }

  Future<bool> deleteProfilePicture(String fileName) async {
    return await _service.deleteProfilePicture(fileName);
  }
}