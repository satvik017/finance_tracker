import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class SessionManager {
  final ValueNotifier<UserProfile?> user = ValueNotifier<UserProfile?>(null);

  void login(UserProfile profile) {
    user.value = profile;
  }

  void logout() {
    user.value = null;
  }

  void dispose() {
    user.dispose();
  }
}
