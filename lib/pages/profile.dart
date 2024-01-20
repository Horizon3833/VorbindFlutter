import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vorbind/helpers/app_user.dart';
import 'package:vorbind/helpers/custom_colors.dart';
import 'package:vorbind/helpers/firebase_initialized.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _formChanged = false;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  File? _image;
  String _imageURL = '';
  late DatabaseReference userRef;
  late String uid;
  late SharedPreferences sharedPreferences;
  bool connected = FirebaseInitialized().connected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (connected) {
      sharedPreferences = await SharedPreferences.getInstance();
      uid = sharedPreferences.getString('uid')!;
      userRef = FirebaseDatabase.instance.ref().child("Users");
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

  void pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
  if (connected) {
    try {
      final storage = FirebaseStorage.instance;
      final reference = storage.ref().child('profile_pics/$uid');

      if (_image != null) {
        if (kIsWeb) {
          await reference.putData(await _image!.readAsBytes());
        } else {
          await reference.putFile(_image!);
        }

        _imageURL = await reference.getDownloadURL();
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error uploading image: $e',
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
      msg: 'Error connecting server, please restart the application',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.sp,
    );
  }
}


  void saveProfile(BuildContext context) async {
    if (connected) {
      try {
        await uploadImage();
        String profilePicPath = _imageURL;
        AppUser appuser = AppUser(
            about: _aboutController.text,
            email: sharedPreferences.getString('email')!,
            name: _userNameController.text,
            profileURL: profilePicPath,
            password: sharedPreferences.getString('password')!);
        await userRef.set({uid: appuser.toJson()});

        // Save user data using shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name', _userNameController.text);
        prefs.setString('about', _aboutController.text);
        prefs.setString('profilePic', profilePicPath);

        Fluttertoast.showToast(
          msg: 'Profile Saved Successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.sp,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: '$e',
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
        msg: 'Profile not saved, as the internet is not connected',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
      Navigator.pushNamed(context, '/home');
    }
  }

  void onFormChange() {
    if (_formChanged) return;
    setState(() {
      _formChanged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.darkGrey[500],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50.h),
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  child: _image != null
                      ? kIsWeb
                          ? ClipOval(
                              child: Image.network(
                                _image!.path,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipOval(
                              child: Image.file(
                                _image!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                      : Image.asset('assets/unknown.png'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                onChanged: onFormChange,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _userNameController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.name,
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
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
                        labelText: 'User Name',
                      ),
                      autofocus: true,
                      validator: (String? val) {
                        if (val!.isEmpty) {
                          return 'Field cannot be left blank';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _aboutController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      maxLength: 50,
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.edit, color: Colors.white),
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
                        labelText: 'About You',
                      ),
                      autofocus: true,
                      validator: (String? val) {
                        if (val!.isEmpty) {
                          return 'Field cannot be left blank';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: _formChanged
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();
                                saveProfile(context);
                              }
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(180, 45),
                        shape: const StadiumBorder(),
                        side: const BorderSide(
                          width: 2,
                          color: Color.fromARGB(255, 20, 255, 204),
                        ),
                        backgroundColor: const Color.fromARGB(255, 0, 206, 171),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
