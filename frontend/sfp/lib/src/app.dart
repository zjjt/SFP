import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/blocs/data_bloc.dart';
import 'package:sfp/src/resources/resources.dart';
import 'package:sfp/src/screens/screens.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      title: 'Super File Processor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          //this is done to disable the transition caused after the splashscreen navigation
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.windows: null,
            },
          ),
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white),
      initialRoute: SplashScreenIntro.route,
      routes: {
        SplashScreenIntro.route: (context) => BlocProvider(
            create: (context) => DataBloc(Repository()),
            child: SplashScreenIntro()),
        HomeScreen.route: (context) => BlocProvider(
            create: (context) => DataBloc(Repository()), child: HomeScreen()),
      },
    );
  }
}
