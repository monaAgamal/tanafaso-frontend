import 'dart:io';

import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/authentication/requests/email_login_request_body.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:azkar/utils/app_localizations.dart';
import 'package:azkar/utils/snack_bar_utils.dart';
import 'package:azkar/views/auth/login/reset_password_screen.dart';
import 'package:azkar/views/auth/signup/signup_main_screen.dart';
import 'package:azkar/views/core_views/home_page.dart';
import 'package:azkar/views/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() {
    return new _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  String _email;
  String _password;
  bool _passwordObscure = true;
  FocusNode passwordFocus;
  String _errorMessage;
  ButtonState progressButtonState;

  @override
  void initState() {
    super.initState();

    passwordFocus = new FocusNode();
    _errorMessage = "";
    _email = "";
    _password = "";
    progressButtonState = ButtonState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: Keys.loginScreen,
        appBar: AppBar(title: Text(AppLocalizations.of(context).login)),
        body: Center(
            child: Container(
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: _loginFormKey,
                  child: new Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: SingleChildScrollView(
                      child: new Column(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(top: 4 * 8.0)),
                          Column(
                            children: [
                              new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: new Padding(
                                      padding:
                                          const EdgeInsets.only(right: 40.0),
                                      child: new Text(
                                        AppLocalizations.of(context).email,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, top: 10.0),
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                ),
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 0.0),
                                child: new Row(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: TextFormField(
                                        obscureText: false,
                                        autofocus: true,
                                        textAlign: TextAlign.left,
                                        onChanged: (email) =>
                                            _email = email.trim(),
                                        onEditingComplete: () =>
                                            passwordFocus.requestFocus(),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'email@example.com',
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 24.0,
                          ),
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                child: new Padding(
                                  padding: const EdgeInsets.only(right: 40.0),
                                  child: new Text(
                                    AppLocalizations.of(context).password,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          new Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 10.0),
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 0.0),
                            child: new Row(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Expanded(
                                  child: TextFormField(
                                    obscureText: _passwordObscure,
                                    focusNode: passwordFocus,
                                    textAlign: TextAlign.left,
                                    onChanged: (password) =>
                                        _password = password,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: GestureDetector(
                                        onTap: () {
                                          setState(() => _passwordObscure =
                                              !_passwordObscure);
                                        },
                                        child: const Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15.0),
                                            child: const Icon(
                                              Icons.remove_red_eye,
                                              color: Colors.grey,
                                            )),
                                      ),
                                      hintText: AppLocalizations.of(context)
                                          .passwordHintText,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 20.0,
                          ),
                          Visibility(
                            visible: _errorMessage.length > 0,
                            maintainSize: false,
                            child: Row(
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _errorMessage,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          new Container(
                            margin: const EdgeInsets.only(
                                left: 30.0, right: 30.0, top: 20.0),
                            alignment: Alignment.center,
                            child: new Row(
                              children: <Widget>[
                                new Expanded(
                                  // ignore: deprecated_member_use
                                  child: getLoginButton(),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: Platform.isAndroid,
                            child: new Container(
                              margin: const EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 20.0),
                              alignment: Alignment.center,
                              child: Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: new Container(
                                      margin: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 0.25)),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context).orLoginWith,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  new Expanded(
                                    child: new Container(
                                      margin: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 0.25)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                              visible: Platform.isAndroid,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 8 * 2.0),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: SignInButton(
                                            Buttons.Google,
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                            onPressed: () {
                                              loginWithGoogle(context);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: SignInButton(
                                            Buttons.Facebook,
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                            onPressed: () {
                                              loginWithFacebook();
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          // ignore: deprecated_member_use
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // ignore: deprecated_member_use
                              new FlatButton(
                                child: new Text(
                                  AppLocalizations.of(context)
                                      .youDoNotHaveAnAccount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15.0,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              new SignUpMainScreen()));
                                },
                              ),
                            ],
                          ),
                          // ignore: deprecated_member_use
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // ignore: deprecated_member_use
                              new FlatButton(
                                child: new Text(
                                  AppLocalizations.of(context).forgotPassword,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15.0,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              new ResetPasswordScreen()));
                                },
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(8)),
                        ],
                      ),
                    ),
                  ),
                ))),
      ),
    );
  }

  Widget getLoginButton() {
    return ProgressButton.icon(
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 25,
      ),
      iconedButtons: {
        ButtonState.idle: IconedButton(
            text: AppLocalizations.of(context).login,
            icon: Icon(Icons.login, color: Colors.black),
            color: Theme.of(context).buttonTheme.colorScheme.primary),
        ButtonState.loading: IconedButton(
            text: AppLocalizations.of(context).sending,
            color: Colors.yellow.shade200),
        ButtonState.fail: IconedButton(
            text: AppLocalizations.of(context).failed,
            icon: Icon(Icons.cancel, color: Colors.white),
            color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            text: "تم تسجيل الدخول بنجاح",
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400)
      },
      onPressed: onProgressButtonClicked,
      state: progressButtonState,
    );
  }

  void onProgressButtonClicked() async {
    if (progressButtonState == ButtonState.success ||
        progressButtonState == ButtonState.loading) {
      return;
    }

    setState(() {
      progressButtonState = ButtonState.loading;
    });

    RegExp regex = new RegExp('^[\\w-_\\.+]*[\\w-_\\.]\\@'
        '([\\w]+\\.)+[\\w]+[\\w]\$');
    if (regex.stringMatch(_email) != _email) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).emailIsInvalid;
        progressButtonState = ButtonState.fail;
      });
      return;
    }
    if (_password.length < 8) {
      setState(() {
        _errorMessage =
            AppLocalizations.of(context).passwordShouldBeOfAtLeast8Characters;
        progressButtonState = ButtonState.fail;
      });
      return;
    }

    loginWithEmail(
        new EmailLoginRequestBody(email: _email, password: _password));
  }

  loginWithFacebook() async {
    try {
      await ServiceProvider.authenticationService.loginWithFacebook();
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      return;
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  loginWithGoogle(BuildContext context) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
    String googleIdToken;
    try {
      GoogleSignInAccount account = await _googleSignIn.signIn();
      GoogleSignInAuthentication authentication = await account.authentication;
      googleIdToken = authentication.idToken;
    } catch (error) {
      print(error);
    }

    try {
      await ServiceProvider.authenticationService
          .loginWithGoogle(googleIdToken);
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      return;
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new HomePage()));
  }

  loginWithEmail(EmailLoginRequestBody request) async {
    try {
      await ServiceProvider.authenticationService.login(request);
    } on ApiException catch (e) {
      SnackBarUtils.showSnackBar(context, e.errorStatus.errorMessage);
      setState(() {
        progressButtonState = ButtonState.fail;
      });
      return;
    }

    setState(() {
      progressButtonState = ButtonState.success;
    });

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => HomePage()), (_) => false);
  }
}
