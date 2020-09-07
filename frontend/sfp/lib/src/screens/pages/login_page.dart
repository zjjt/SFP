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
  AuthBloc authBloc;
  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
    authBloc = context.bloc<AuthBloc>();
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
                        switch (state.status) {
                          case AuthStatus.unknown:
                            break;
                          case AuthStatus.authenticated:
                            //here we redirect to another page
                            break;
                          case AuthStatus.loading:
                            //here we switch state of the login button
                            break;
                          case AuthStatus.unauthenticated:
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
                              obscureText: showPassword,
                              controller: passwordController,
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
                              child: RaisedButton(
                                onPressed: _login,
                                color: Assets.ubaRedColor,
                                textColor: Colors.white,
                                child: Text("Log in",
                                    style: const TextStyle(fontSize: 16)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                            ),
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
