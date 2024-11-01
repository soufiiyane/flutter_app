class SessionManager {
  // Singleton instance
  static final SessionManager _instance = SessionManager._internal();

  // Private constructor
  SessionManager._internal();

  // Factory constructor for accessing the instance
  factory SessionManager() => _instance;

  // Variable to hold the email of the logged-in user
  String? userEmail;

  // Method to clear session (e.g., on logout)
  void clearSession() {
    userEmail = null;
  }
}
