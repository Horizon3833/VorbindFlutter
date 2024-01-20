import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VorbindAuthProvider with ChangeNotifier {
  UserCredential? _userCredential;

  UserCredential? get userCredential => _userCredential;

  void setUserCredential(UserCredential userCredential) {
    _userCredential = userCredential;
    notifyListeners();
  }

  void clearUserCredential() {
    _userCredential = null;
    notifyListeners();
  }

   static VorbindAuthProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<VorbindAuthProvider>(context, listen: listen);
  }
}
