import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isErrorMsg = false;
  AuthBloc authBloc;
  NavBloc navBloc;
  AnimateEntranceBloc animateBloc;
  String message = "Please enter your credentials above";
  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
    authBloc = context.bloc<AuthBloc>();
    navBloc = context.bloc<NavBloc>();
    animateBloc = context.bloc<AnimateEntranceBloc>();
    //launching entrence animation
    animateBloc.add(EnteringPage());
    showPassword = true;
  }

  void _login() {
    if (_formKey.currentState.validate()) {
      final email = emailController.text;
      final password = passwordController.text;
      //submitting to the server
      authBloc.add(LoggingIn(email, password));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size appB = Size(
        Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width / 3.0
            : MediaQuery.of(context).size.width,
        80.0);
    return Container(
      width: appB.width,
      //height: 500,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 150.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Sign In !",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Assets.ubaRedColor,
                      fontSize: 50.0,
                    ),
                  ),
                  SizedBox(height: 50.0),
                  Container(
                    padding: Responsive.isMobile(context)
                        ? const EdgeInsets.symmetric(horizontal: 30.0)
                        : const EdgeInsets.all(0),
                    child: BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        print("state status is ${state.status}");
                        switch (state.status) {
                          case AuthStatus.unknown:
                            setState(() {
                              isErrorMsg = false;
                              message = "Please enter your credentials above";
                            });
                            break;
                          case AuthStatus.authenticated:
                            //here we redirect to another page
                            setState(() {
                              isErrorMsg = false;
                              message = "welcome dear staff member";
                            });
                            Timer(Duration(milliseconds: 100), () {
                              animateBloc.add(LeavingPage());
                              Timer(Duration(milliseconds: 500), () {
                                if (state.user.role == "ADMIN") {
                                  navBloc.add(GoAdmin());
                                  //TO REMOVE AFTER CREATING THE PAGE
                                  animateBloc.add(EnteringPage());
                                } else if (state.user.validations != null &&
                                    state.user.validations.isNotEmpty) {
                                  navBloc.add(GoValidate());
                                  //TO REMOVE AFTER CREATING THE PAGE
                                  animateBloc.add(EnteringPage());
                                } else {
                                  navBloc.add(GoConfig());
                                }
                              });
                            });
                            break;
                          case AuthStatus.loading:
                            //here we switch state of the login button
                            setState(() {
                              isErrorMsg = false;
                              message =
                                  "Please wait while we process your informations";
                            });
                            break;
                          case AuthStatus.unauthenticated:
                            setState(() {
                              isErrorMsg = true;
                              message = state.errorMsg ??
                                  "Please verify your credentials.";
                            });
                            break;
                        }
                      },
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (mail) {
                                if (!EmailValidator.validate(mail)) {
                                  return "Please fill in a proper email id";
                                }
                                return null;
                              },
                              controller: emailController,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.person_outline,
                                  color: Assets.ubaRedColor,
                                ),
                                labelText: "Email",
                                labelStyle: TextStyle(
                                  color: Assets.ubaRedColor,
                                  fontSize: 15.0,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Assets.ubaRedColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              onFieldSubmitted: (event) => _login(),
                              obscureText: showPassword,
                              controller: passwordController,
                              validator: (password) {
                                if (password.isEmpty) {
                                  return 'Please fill in your password before submitting the form';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off_outlined,
                                    color: Assets.ubaRedColor,
                                  ),
                                  onPressed: () => setState(
                                      () => showPassword = !showPassword),
                                  tooltip: showPassword
                                      ? "Show password"
                                      : "Hide password",
                                ),
                                labelText: "Password",
                                labelStyle: TextStyle(
                                  color: Assets.ubaRedColor,
                                  fontSize: 15.0,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Assets.ubaRedColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              width: appB.width * 0.5,
                              height: 40.0,
                              child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                return RaisedButton(
                                  onPressed: _login,
                                  color: Assets.ubaRedColor,
                                  hoverColor: Colors.black,
                                  textColor: Colors.white,
                                  child: state.status == AuthStatus.loading
                                      ? CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                        )
                                      : Text("Log in",
                                          style: const TextStyle(fontSize: 16)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 40.0),
                            Text(message,
                                style: TextStyle(
                                    color:
                                        isErrorMsg ? Colors.red : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
