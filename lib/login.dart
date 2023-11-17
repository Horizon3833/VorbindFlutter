import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'animations/logo_animation.dart';
import 'helpers/error_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showCreateAccount = false;
  bool _showPassword = false;
  bool _showProfileSetup = false;
  late String _verificationID;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  late File _image;
  late String _imageUrl;
  late String _errorMessage;
  bool _showErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        const LogoAnimation(),
        const DefaultTextStyle(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
          child: Text('Vorbind'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 45.0),
          child: Card(
            elevation: 20.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!_showProfileSetup)
                    Column(
                      children: [
                        if (!_showCreateAccount)
                          TextField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        if (_showCreateAccount)
                          TextField(
                            controller: _otpController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'OTP',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            if (!_showCreateAccount) {
                              _verifyPhoneNumber();
                            } else {
                              _signInWithPhoneNumber();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            _showCreateAccount ? 'Verify OTP' : 'Send OTP',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showCreateAccount = !_showCreateAccount;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            _showCreateAccount
                                ? 'Resend OTP'
                                : 'Don\'t have an account? Create new',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  if (_showProfileSetup)
                    Card(
                      elevation: 15.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            TextField(
                              controller: _aboutController,
                              decoration: const InputDecoration(
                                labelText: 'About',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Pick Profile Picture'),
                            ),
                            SizedBox(
                              height: 100,
                              child: Image.file(_image),
                            ),
                            const SizedBox(height: 10.0),
                            ElevatedButton(
                              onPressed: () async {
                                await _uploadImage();
                                _saveUserProfile();
                                // Navigate to the chat screen or any other screen after setup
                              },
                              child: const Text('Complete Setup'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if(_showErrorMessage)
          ErrorMessage(_errorMessage),
      ]),
    );
  }

  void _verifyPhoneNumber() async {
    try {
      verified(AuthCredential authResult) {
        _auth.signInWithCredential(authResult);
      }

      verificationFailed(FirebaseAuthException authException) {

      }

      codeSent(String verificationId, [int? forceResendingToken]) async {
        // You can store the verification ID to use it for user authentication.
        // Save verification ID and show the OTP screen.
        _verificationID = verificationId;
      }


      codeAutoRetrievalTimeout(String verificationId) {
        // Auto-resolution timed out...
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      _showMessage('Error: $e', true);
    }
  }

  void _signInWithPhoneNumber() async {
    try {
      AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: _otpController.text,
        smsCode: _otpController.text,
      );

      await _auth.signInWithCredential(authCredential);
      setState(() {
        _showProfileSetup = true;
      });
    } catch (e) {
      _showMessage('Error: $e', true);
    }
  }

  void _showMessage(String message, bool show) async {
    setState(() {
      _showErrorMessage = show;
      _errorMessage = message;
      Future.delayed(const Duration(seconds: 1));
      _showErrorMessage = false;
    });
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImage() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        final storage = FirebaseStorage.instance;
        final reference =
        storage.ref().child('profile_pics/${user.uid}.jpg');
        await reference.putFile(_image);
        _imageUrl = await reference.getDownloadURL();
      } else {
        _showMessage('User is null', true);
        // Handle the case where _auth.currentUser is null
      }
        } catch (e) {
      _showMessage('Error uploading image: $e', true);
    }
  }


  void _saveUserProfile() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': _usernameController.text,
          'about': _aboutController.text,
          'profile_pic': _imageUrl,
          // Add other fields as needed
        });
      } else {
        _showMessage('No authenticated user', true);
        // Handle the case where there is no authenticated user
      }
    } catch (e) {
      _showMessage('Error saving user profile: $e', true);
    }
  }
}

class ElevatedCard extends StatelessWidget {
  final Widget child;

  const ElevatedCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

class BaseCard extends StatelessWidget {
  final Widget child;

  const BaseCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380.0,
      child: Card(
        elevation: 20.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
