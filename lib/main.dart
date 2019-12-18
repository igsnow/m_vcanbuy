import 'package:base_library/base_library.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:m_vcanbuy/pages/splash_page.dart';
import 'package:m_vcanbuy/route/routes.dart';
import 'package:m_vcanbuy/widgets/browser.dart';

import 'application.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Router router = Router();
    Routes.configureRoutes(router);
    Application.router = router;

    return MaterialApp(
      title: 'Vcanbuy',
      onGenerateRoute: Application.router.generator,
      home: new SplashPage(),
    );
  }
}
