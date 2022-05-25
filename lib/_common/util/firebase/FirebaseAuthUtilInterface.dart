abstract class FirebaseAuthUtilInterface<USER> {
  bool haveEverGetUser = false;
  bool haveEverInit = false;

  Future<void> init();

  Future<USER?> getUser();

  Future<void> updateProfile({String? displayName, String? photoUrl});

  Future<USER?> loginAnonymously();

  Future<USER?> registerWithEmail(
      {required String email, required String password});

  Future<void> sendEmailVerification();

  Future<USER?> loginWithEmail(
      {required String email, required String password});

  Future<void> logout();

  Future<void> delete();
}
