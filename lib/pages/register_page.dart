import 'dart:io';

import 'package:chat/consts.dart';
import 'package:chat/models/user_profile.dart';
import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:chat/services/storage_service.dart';
import 'package:chat/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  late AuthService _authService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  File? selectedImage;
  String? name, email, password;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            _headerText(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.03,
            ),
            _photoSelectionField(),
            if (!isLoading) _signupForm(),
            if (!isLoading) _haveAccount(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lets Get Going!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Regsiter an account using below form",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signupForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomFormField(
              hintText: "Name",
              validateRegEx: NAME_VALIDATION_REGEX,
              onSaved: (value) {
                name = value;
              },
              icon: Icons.person,
            ),
            CustomFormField(
              hintText: "Email",
              validateRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                email = value;
              },
              icon: Icons.email_outlined,
            ),
            CustomFormField(
              hintText: "Password",
              validateRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                password = value;
              },
              icon: Icons.password_outlined,
            ),
            _signupButton(),
          ],
        ),
      ),
    );
  }

  Widget _photoSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _signupButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Register",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _registerFormKey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPhoto(
                  file: selectedImage!,
                  uid: _authService.user!.uid,
                );
                if (pfpURL != null) {
                  await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                      uid: _authService.user!.uid,
                      name: name,
                      pfpURL: pfpURL,
                    ),
                  );
                  _alertService.showToast(
                    text: "User Registration Completed",
                    icon: Icons.check,
                  );
                  _navigationService.goBack();
                  _navigationService.pushReplacementNamed("/home");
                } else {
                  throw Exception("Unable to upload profile picture");
                }
              } else {
                throw Exception("Unable to register user");
              }
            }
          } catch (e) {
            print(e);
            _alertService.showToast(
              text: "Failed to Register, Please try again!",
              icon: Icons.error,
            );
          }
          setState(() {
            isLoading = false;
          });
        },
      ),
    );
  }

  Widget _haveAccount() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already Have An Account? "),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
