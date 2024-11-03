class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  SessionManager._internal();

  factory SessionManager() => _instance;

  String? userEmail;

  void clearSession() {
    userEmail = null;
  }
}
