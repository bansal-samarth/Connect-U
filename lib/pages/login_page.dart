import 'package:chat/consts.dart';
import 'package:chat/services/alert_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:chat/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
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
            _loginform(),
            _donthaveAccount(),
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
            "Hi There, Welcome Back!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Hello again, you've been missed",
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

  Widget _loginform() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomFormField(
              hintText: "Email",
              icon: Icons.mail_outline_outlined,
              validateRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.03,
            ),
            CustomFormField(
              hintText: "Password",
              icon: Icons.remove_red_eye_outlined,
              validateRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.03,
            ),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);
            print(result);
            if (result) {
              _navigationService.pushReplacementNamed("/home");
            } else {
              _alertService.showToast(
                text: "Failed to login, Please try again!",
                icon: Icons.error_outline,
              );
            }
          }
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "LOGIN",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _donthaveAccount() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't Have A Account? "),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed("/register");
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
