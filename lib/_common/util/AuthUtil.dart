import 'package:crawller_backend/_common/model/exception/CommonException.dart';
import 'package:crawller_backend/_common/util/LogUtil.dart';
import 'package:crawller_backend/_common/util/firebase/FirebaseAuthUtilInterface.dart';
import 'package:crawller_backend/_common/util/firebase/firedart/FiredartAuthSingleton.dart';

enum NeededAuthBehavior { NEED_LOGIN, NEED_VERIFICATION, NEED_REGISTRATION }

class AuthUtil {
  String? email;

  static final AuthUtil _singleton = AuthUtil._internal();

  factory AuthUtil() {
    return _singleton;
  }

  AuthUtil._internal();

  /*
  무료로 이메일 인증을 사용하기 위한 정책.
  1. 이메일+기본값 비밀번호로 회원가입 시키고, 이메일 인증을 요청함
  2. 회원가입이 되었다면, 기본값 회원가입+로그인이 실패할 것임,
  3. 회원가입이 안되었다면, 기본값 회원가입+로그인이 성공할 것임.
  4. 이메일 인증을 파악하기 위해서, 해당 유저의 user.displayName를 사용하기로 한다.
      회원가입이 완료되면, user.displayName을 ""로 변경할 것임 (기본값 null)
  5. 따라서, isLogin에서 displayName이 null이라면, 로그아웃시키고, 로그인안된것으로 처리해야한다.
   */

  late final FirebaseAuthUtilInterface _firebaseAuthUtilInterface;
  static const _password = "tempNewPassword";
  static const _nameRegistered = "nameRegistered";

  Future<void> init() async {
    _firebaseAuthUtilInterface = FiredartAuthSingleton();

    await _firebaseAuthUtilInterface.init();
  }

  Future<void> checkIsRegistered() async {
    // LogUtil.debug("checkIsRegistered 1");
    dynamic user = await _firebaseAuthUtilInterface.getUser();
    // LogUtil.debug("checkIsRegistered 2");

    if (user != null && user.displayName != _nameRegistered) {
      // LogUtil.debug("checkIsRegistered 3");
      await logout();
      // LogUtil.debug("checkIsRegistered 4");
    }
  }

  Future<bool> isLogin() async {
    // LogUtil.debug("isLogin 1");
    await checkIsRegistered();
    // LogUtil.debug("isLogin 2");

    dynamic user = await _firebaseAuthUtilInterface.getUser();
    if(user != null) {
      this.email = user.email??"";
    }
    LogUtil.debug("user : ${user}");

    return (user != null);
  }

  Future<NeededAuthBehavior> sendEmailVerification(
      {required String email}) async {
    try {
      await _firebaseAuthUtilInterface.registerWithEmail(
          email: email, password: _password);
    } on CommonException catch (e) {
      if (e.code == "email-already-in-use") {
        try {
          await loginWithEmailDefaultPassword(email);
        } on CommonException catch (e2) {
          if (e2.code == "wrong-password") {
            return NeededAuthBehavior.NEED_LOGIN;
          }
        }
      }
    }

    try {
      await _firebaseAuthUtilInterface.sendEmailVerification();
    } on CommonException catch (e) {
      if (e.code == 'email-already-in-use') {
        return NeededAuthBehavior.NEED_LOGIN;
      } else {
        return NeededAuthBehavior.NEED_REGISTRATION;
      }
    }

    await _firebaseAuthUtilInterface.logout();
    return NeededAuthBehavior.NEED_VERIFICATION;
  }

  Future<void> logout() async {
    await _firebaseAuthUtilInterface.logout();
  }

  Future<void> loginWithEmailDefaultPassword(String email) async {
    await _firebaseAuthUtilInterface.loginWithEmail(
        email: email, password: _password);
  }

  Future<void> loginWithEmail(String email, String password) async {
    await _firebaseAuthUtilInterface.loginWithEmail(
        email: email, password: password);
    this.email = email;
    LogUtil.debug("loginWithEmail user : ${await _firebaseAuthUtilInterface.getUser()}");
  }

  Future<void> delete() async {
    await _firebaseAuthUtilInterface.delete();
    await _firebaseAuthUtilInterface.logout();
  }

  Future<void> registerWithEmail(String email, String password) async {
    await _firebaseAuthUtilInterface.registerWithEmail(
        email: email, password: password);
    await _firebaseAuthUtilInterface.updateProfile(
        displayName: _nameRegistered);
    this.email = email;
  }

  Future<bool> emailIsVerified() async {
    return ((await _firebaseAuthUtilInterface.getUser())?.emailVerified ??
        false);
  }
}
