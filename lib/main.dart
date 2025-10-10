import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:name_meaning/pages/MainPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ]);
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
        popupMenuTheme: PopupMenuThemeData(color: Colors.white),
        scaffoldBackgroundColor: Colors.white

      ),
      home: MainPage()
    );
  }
}
 