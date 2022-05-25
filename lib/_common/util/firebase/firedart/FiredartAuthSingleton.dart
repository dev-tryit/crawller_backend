import 'dart:convert';

import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:hive/hive.dart';
import 'package:crawller_backend/MySetting.dart';
import 'package:crawller_backend/_common/model/exception/CommonException.dart';
import 'package:crawller_backend/_common/util/LogUtil.dart';
import 'package:crawller_backend/_common/util/firebase/FirebaseAuthUtilInterface.dart';

class FiredartAuthSingleton extends FirebaseAuthUtilInterface {
  static final FiredartAuthSingleton _singleton =
      FiredartAuthSingleton._internal();

  factory FiredartAuthSingleton() {
    return _singleton;
  }

  FiredartAuthSingleton._internal();

  FirebaseAuth get _instance => FirebaseAuth.instance;

  @override
  Future<void> init() async {
    if (!haveEverInit) {
      haveEverInit = true;

      FirebaseAuth.initialize(
          MySetting.firebaseWebConfig["apiKey"], await HiveStore.create());
      // _instance.signInState.listen((state) {
      //   LogUtil.debug("Signed ${state ? "in" : "out"}");
      // });
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    User? user = await getUser();
    if (user == null) {
      LogUtil.error("user is null");
      return;
    }

    await _instance.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<User?> getUser() async {
    try {
      var user = await _instance.getUser();
      LogUtil.debug("user : $user");
      return user;
    } on SignedOutException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> loginAnonymously() async {
    try {
      await _instance.signInAnonymously();
      return await getUser();
    } on AuthException catch (e) {
      var code = e.message;
      throw CommonException(code: code);
    }
  }

  @override
  Future<User?> registerWithEmail(
      {required String email, required String password}) async {
    try {
      await _instance.signUp(email, password);
      return await getUser();
    } on AuthException catch (e) {
      var code = e.message;
      if (code == 'EMAIL_EXISTS') {
        throw CommonException(
            message: "이미 ID가 있습니다", code: "email-already-in-use");
      } else if (code == 'TOO_MANY_ATTEMPTS_TRY_LATER') {
        throw CommonException(
            message: "잠시 후에 다시 시도해주세요", code: "too-many-requests");
      } else {
        throw CommonException(code: code);
      }
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    User? user = await getUser();
    if (user == null) {
      LogUtil.error("user is null");
      return;
    }

    try {
      await _instance.requestEmailVerification(
          langCode: MySetting.defaultLangCode);
    } on AuthException catch (e) {
      var code = e.message;
      if (code == 'EMAIL_EXISTS') {
        throw CommonException(
            message: "이미 ID가 있습니다", code: "email-already-in-use");
      } else {
        LogUtil.error("FireauthUtil.sendEmailVerification ${code}");
      }
    }
  }

  @override
  Future<User?> loginWithEmail(
      {required String email, required String password}) async {
    try {
      await _instance.signIn(email, password);
      return await getUser();
    } on AuthException catch (e) {
      var code = e.message;
      if (code == 'EMAIL_NOT_FOUND') {
        return null;
      } else if (code == 'INVALID_PASSWORD') {
        throw CommonException(message: "비밀번호가 틀렸습니다", code: "wrong-password");
      } else {
        throw CommonException(code: code);
      }
    }
  }

  @override
  Future<void> logout() async {
    _instance.signOut();
  }

  @override
  Future<void> delete() async {
    try {
      User? user = await getUser();
      if (user != null) {
        await _instance.deleteAccount();
      }
    } catch (e) {
      LogUtil.error("FireauthUtil.delete error $e");
    }
  }
}

const keyToken = "auth_token";

class HiveStore extends TokenStore {
  static Future<HiveStore> create() async {
    //기본위치는 내문서에 저장됨.
    final box = await Hive.openBox("auth_store",
        compactionStrategy: (entries, deletedEntries) => deletedEntries > 50);
    return HiveStore._internal(box);
  }

  final Box _box;

  HiveStore._internal(this._box);

  @override
  Token? read() => _box.get(keyToken);

  @override
  void write(Token? token) => token != null ? _box.put(keyToken, token) : null;

  @override
  void delete() => _box.delete(keyToken);
}

class TokenAdapter extends TypeAdapter<Token> {
  @override
  final typeId = 42;

  @override
  void write(BinaryWriter writer, Token obj) => writer.writeMap(obj.toMap());

  @override
  Token read(BinaryReader reader) =>
      Token.fromMap(reader.readMap().map<String, dynamic>(
          (key, value) => MapEntry<String, dynamic>(key, value)));
}
