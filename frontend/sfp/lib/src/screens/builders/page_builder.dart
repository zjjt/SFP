import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/screens/pages/pages.dart';

class PageBuilder extends StatefulWidget {
  PageBuilder({Key key}) : super(key: key);

  @override
  _PageBuilderState createState() => _PageBuilderState();
}

class _PageBuilderState extends State<PageBuilder> {
  String userRole = "";
  bool hasValidationsPending = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBloc, NavState>(
      builder: (context, state) {
        if (state is LoginState) {
          return LoginPage();
        } else if (state is AdminState) {
          return Container(
              child: Center(
            child: Text("Admin page here"),
          ));
        } else if (state is WhereTo) {
          return Container(
              child: Center(
            child: Text("Custom page here ${state.where}"),
          ));
        } else if (state is ValidationState) {
          return Container(
              child: Center(
            child: Text("validation page here"),
          ));
        } else {
          return LoginPage();
        }
      },
    );
  }
}
