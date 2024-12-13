class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  SessionManager._internal();

  factory SessionManager() => _instance;

  String? userEmail;
  String? firstName;
  String? lastName;
  String? profileImageUrl;


 void clear() {
    userEmail = null;
    firstName = null;
    lastName = null;
    profileImageUrl = null;
  }
}