import "package:ciclo_core/ciclo_core.dart";
import "package:flutter/foundation.dart";

class SessionStore extends ChangeNotifier {
  AuthSession? session;

  bool get isSignedIn => session != null;
  UserProfile? get user => session?.user;
  String? get token => session?.token;

  void signIn(AuthSession value) {
    session = value;
    notifyListeners();
  }

  void updateUser(UserProfile user) {
    final current = session;
    if (current == null) return;
    session = AuthSession(token: current.token, user: user);
    notifyListeners();
  }

  void signOut() {
    session = null;
    notifyListeners();
  }
}
