import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/features/authentication/view_models/signup_view_model.dart';
import 'package:tiktok_clone/features/users/models/user_profile_model.dart';
import 'package:tiktok_clone/features/users/repos/user_repo.dart';

class UsersViewModel extends AsyncNotifier<UserProfileModel> {
  late final UserRepository _repository;

  @override
  FutureOr<UserProfileModel> build() {
    _repository = ref.read(userRepo);
    return UserProfileModel.empty();
  }

  Future<void> createProfile(UserCredential credential) async {
    if (credential.user == null) throw Exception("Account not created");

    state = const AsyncValue.loading();
    final form = ref.read(signUpForm);

    // 更新 user profile 到 model
    final profile = UserProfileModel(
      bio: "undefined",
      link: "undefined",
      uid: credential.user!.uid,
      email: form["email"],
      name: form["name"],
      birthday: form["birthday"],
    );

    // 更新到 database
    await _repository.createProfile(profile);

    state = AsyncValue.data(profile);
  }
}

final usersProvider = AsyncNotifierProvider<UsersViewModel, UserProfileModel>(
  () => UsersViewModel(),
);
