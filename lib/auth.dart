import 'dart:async';

abstract class BaseAuth {
  Future<String> currentUser();
  Future<String> signIn(String email, String password);
  Future<String> createUser(String email, String password);
  Future<void> signOut();
}

class Auth implements BaseAuth {
  String user;

  Future<String> signIn(String email, String password) async {
    if (email == 'test@test.com' && password == '111') {
      user = email;
    } else {
      throw("wrong user $email");
    }

    return user;
  }

  Future<String> createUser(String email, String password) async {
    return '';
  }

  Future<String> currentUser() async {
    return user;
  }

  Future<void> signOut() async {
    user = null;
    return user;
  }
}
