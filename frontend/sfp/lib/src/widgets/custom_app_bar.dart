import 'package:flutter/material.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/widgets/widgets.dart';

class CustomAppBar extends StatelessWidget {
  final Function helpOnPressed;
  final Function logOut;
  final bool userConnected;
  const CustomAppBar(
      {Key key,
      @required this.helpOnPressed,
      @required this.logOut,
      this.userConnected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Responsive(
        mobile: _AppBarMobile(
          helpOnPressed: helpOnPressed,
          logOut: logOut,
          userConnected: userConnected,
        ),
        desktop: _AppBarDesktop(
          helpOnPressed: helpOnPressed,
          logOut: logOut,
          userConnected: userConnected,
        ),
      ),
    );
  }
}

class _AppBarDesktop extends StatelessWidget {
  final Function helpOnPressed;
  final Function logOut;
  final bool userConnected;
  const _AppBarDesktop(
      {Key key, this.helpOnPressed, this.logOut, this.userConnected})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Assets.ubaRedColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Image.asset(
          Assets.ubaWelLogo,
          fit: BoxFit.fitWidth,
          // height: 300.0,
          // width: 400.0,
        ),
      ),
      title: Text(
        "Simple File Processor",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: helpOnPressed,
          color: Colors.transparent,
          icon: Icon(
            Icons.help_outlined,
            color: Colors.white,
          ),
          tooltip: "Help menu",
        ),
        //here we check if user is connected so we can display logout button
        userConnected
            ? IconButton(
                onPressed: logOut,
                color: Colors.transparent,
                icon: Icon(
                  Icons.exit_to_app_outlined,
                  color: Colors.white,
                ),
                tooltip: "Log out",
              )
            : SizedBox()
      ],
    );
  }
}

class _AppBarMobile extends StatelessWidget {
  final Function helpOnPressed;
  final Function logOut;
  final bool userConnected;

  const _AppBarMobile(
      {Key key, this.helpOnPressed, this.logOut, this.userConnected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Image.asset(Assets.ubaRedSigleT, fit: BoxFit.cover),
      ),
      title: Text(
        "Simple File Processor",
        style: const TextStyle(
          color: Assets.ubaRedColor,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: helpOnPressed,
          color: Colors.transparent,
          icon: Icon(
            Icons.help_outlined,
            color: Assets.ubaRedColor,
          ),
          tooltip: "Help menu",
        ),
        //here we check if user is connected so we can display logout button
        userConnected
            ? IconButton(
                onPressed: logOut,
                color: Colors.transparent,
                icon: Icon(
                  Icons.exit_to_app_outlined,
                  color: Assets.ubaRedColor,
                ),
                tooltip: "Log out",
              )
            : SizedBox()
      ],
    );
  }
}
