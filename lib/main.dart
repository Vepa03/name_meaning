import 'package:flutter/material.dart';
import 'package:name_meaning/pages/MainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white
        ),
        scaffoldBackgroundColor: Colors.white

      ),
      home: MainPage()
    );
  }
}
 