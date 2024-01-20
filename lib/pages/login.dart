import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vorbind/animations/logo_animation.dart';
import 'package:vorbind/helpers/auth_provider.dart';
import 'package:vorbind/helpers/custom_colors.dart';
import 'package:vorbind/helpers/firebase_initialized.dart';
import 'package:vorbind/helpers/app_user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showSignUp = true;
  bool _formChanged = false;
  bool _showPassword = false;
  bool connected = FirebaseInitialized().connected;
  bool debugging = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _email;
  String _confirmPassword = '';
  late String _password;

  late DatabaseReference userRef;
  late BuildContext loginPageContext;
  late UserCredential userCredential;

  @override
  void initState() {
    super.initState();
    if (connected) {
      userRef = FirebaseDatabase.instance.ref().child("Users");
      Fluttertoast.showToast(
        msg: 'Connected Successfully',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Unable to connect',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    loginPageContext = context;
    return Scaffold(
      backgroundColor: CustomColors.darkGrey[500],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const LogoAnimation(),
          if (!_showSignUp) loginScreen,
          if (_showSignUp) signUpScreen,
        ],
      ),
    );
  }

  void _onLoginPressed() async {
    if (debugging) {
      Navigator.pushNamed(loginPageContext, '/profile');
    }
    if (connected) {
      try {
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);

        // Fetch user data from Firebase Realtime Database
        DatabaseReference userReference = FirebaseDatabase.instance
            .ref()
            .child("Users")
            .child(userCredential.user!.uid);
        DataSnapshot snapshot = (await userReference.once()) as DataSnapshot;
        Map<String, dynamic>? userData =
            snapshot.value as Map<String, dynamic>?;
        late AppUser appUser;
        if (userData != null) {
          appUser = AppUser.fromJson(userData);
        }

        // Save user data using shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name', appUser.name);
        prefs.setString('about', appUser.about);
        prefs.setString('profilePic', appUser.profileURL);
        prefs.setString('email', appUser.email);
        prefs.setString('password', appUser.password);
        prefs.setString('uid', userCredential.user!.uid);
        prefs.setBool('login', true);
        Navigator.pushNamed(loginPageContext, '/profile');
            } on FirebaseAuthException {
        Fluttertoast.showToast(
          msg:
              'There was some problem while connecting to the server, please restart the application',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.sp,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Error while connecting to server, please check your internet.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
    }
  }

  Future<void> _onSignUpPressed() async {
    await signUp(_email, _confirmPassword, "New User", "User", "unknown.png");
  }

  Future<void> signUp(String email, String password, String about,
      String userName, String profilePicPath) async {
    try {
      String encPassword = encryptPassword(password);
      try {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        VorbindAuthProvider.of(context).setUserCredential(userCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Fluttertoast.showToast(
            msg: 'The password provided is too weak.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.sp,
          );
        } else if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
            msg: 'The account already exists for that email.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.sp,
          );
        } else {
          Fluttertoast.showToast(
            msg:
                'There was some problem while connecting to the services, plesae check your internet connection.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.sp,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg:
              'An Error was occurred while connecting to the services, please check your internet connection',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.sp,
        );
      }

      AppUser appUser = AppUser(
          about: about,
          email: email,
          password: encPassword,
          name: userName,
          profileURL: profilePicPath);
      await userRef.set({userCredential.user!.uid: appUser.toJson()});

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('name', userName);
      prefs.setString('about', about);
      prefs.setString('profilePic', profilePicPath);
      prefs.setString('email', email);
      prefs.setString('password', encPassword);
      prefs.setString('uid', userCredential.user!.uid);
      prefs.setBool('login', true);
      Fluttertoast.showToast(
        msg: 'Signed Up',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
      Navigator.pushNamed(loginPageContext, '/profile');
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
    }
  }

  String encryptPassword(String password) {
    final salt = BCrypt.gensalt();
    final hash = BCrypt.hashpw(password, salt);
    return hash;
  }

  Widget get signUpScreen {
    return Container(
        color: CustomColors.darkGrey[500],
        child: Form(
          key: _formKey,
          onChanged: _onFormChange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 20.h,
                    bottom: 5.h,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontFamily: 'Roboto'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: const Text(
                    'To create an account, please continue',
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey, fontFamily: 'Roboto'),
                  ),
                ),
              ]),
              Padding(
                padding: EdgeInsets.fromLTRB(80.w, 50.h, 80.w, 5.h),
                child: TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.white,
                  onSaved: (String? val) => _email = val!,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    labelText: 'Email',
                  ),
                  autofocus: true,
                  validator: (String? val) {
                    if (val!.isEmpty) {
                      return 'Field cannot be left blank';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(80.w, 5.h, 80.w, 5.h),
                child: TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  onSaved: (String? val) => _password = val!,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _showPassword,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    suffixIcon: IconButton(
                      color: Colors.white,
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  autofocus: true,
                  validator: (String? val) {
                    if (val!.isEmpty) {
                      return 'Field cannot be left blank';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(80.w, 10.h, 80.w, 50.h),
                child: TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  onSaved: (String? val) {
                    if (val == _password) {
                      _confirmPassword = val!;
                    }
                  },
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _showPassword,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      color: Colors.white,
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  validator: (String? val) {
                    if (val!.isEmpty) {
                      return 'Field cannot be left blank';
                    }
                    return null;
                  },
                ),
              ),
              OutlinedButton(
                onPressed: _formChanged
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          if (_confirmPassword.isNotEmpty) {
                            if (_email.contains('@') && _email.contains('.')) {
                              _onSignUpPressed();
                            }
                          }
                        }
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(180.w, 45.h),
                  shape: const StadiumBorder(),
                  side: const BorderSide(
                      width: 2, color: Color.fromARGB(255, 20, 255, 204)),
                  backgroundColor: const Color.fromARGB(255, 0, 206, 171),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 20.h)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showSignUp = false;
                  });
                },
                child: const Text(
                  'Already have an account? Sign In.',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ));
  }

  Widget get loginScreen {
    return Container(
      color: CustomColors.darkGrey[500],
      child: Form(
          key: _formKey,
          onChanged: _onFormChange,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 30.h,
                  bottom: 5.h,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 25, color: Colors.white, fontFamily: 'Roboto'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: const Text(
                  'To Login please continue',
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey, fontFamily: 'Roboto'),
                ),
              ),
            ]),
            Padding(
              padding: EdgeInsets.fromLTRB(80.w, 80.h, 80.w, 10.h),
              child: TextFormField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
                keyboardType: TextInputType.emailAddress,
                onSaved: (String? val) => _email = val!,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Color(0xFFFFFFFF),
                  )),
                  labelText: 'Email',
                ),
                validator: (String? val) {
                  if (val!.isEmpty) {
                    return 'Field cannot be left blank';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(80.w, 10.h, 80.w, 80.h),
              child: TextFormField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
                onSaved: (String? val) => _password = val!,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _showPassword,
                decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.white,
                    )),
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    suffixIcon: IconButton(
                      color: Colors.white,
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    )),
                validator: (String? val) {
                  if (val!.isEmpty) {
                    return 'Field cannot be left blank';
                  }
                  return null;
                },
              ),
            ),
            OutlinedButton(
                onPressed: _formChanged
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          _onLoginPressed();
                        }
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                    minimumSize: Size(180.w, 45.h),
                    shape: const StadiumBorder(),
                    side: const BorderSide(
                        width: 2, color: Color.fromARGB(255, 20, 255, 204)),
                    backgroundColor: const Color.fromARGB(255, 0, 206, 171)),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )),
            Padding(padding: EdgeInsets.only(top: 20.h)),
            TextButton(
                onPressed: () {
                  setState(() {
                    _showSignUp = true;
                  });
                },
                child: const Text(
                  'Don\'t have account? Create new account.',
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ])),
    );
  }

  void _onFormChange() {
    if (_formChanged) return;
    setState(() {
      _formChanged = true;
    });
  }
}
