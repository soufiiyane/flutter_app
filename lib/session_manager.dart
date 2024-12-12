class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  SessionManager._internal();

  factory SessionManager() => _instance;

  String? userEmail;
  String? firstName;
  String? lastName;

  void clearSession() {
    userEmail = null;
    firstName = null;
    lastName = null;
  }
}