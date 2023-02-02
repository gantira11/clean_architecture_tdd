import 'package:flutter/material.dart';

import '../../features/number_trivia/presentation/pages/number_trivia_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const NumberTriviaPage());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found!'),
        ),
        body: const Center(
            child: Text(
          'Error 404',
          style: TextStyle(fontSize: 32),
        )),
      ),
    );
  }
}
