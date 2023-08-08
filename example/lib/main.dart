import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'views/home/home_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      builder: (context) {
        return MaterialApp(
          title: 'Flutter Demo',
          home: HomeView(),
        );
      },
    );
  }
}
