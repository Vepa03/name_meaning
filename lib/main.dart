import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:name_meaning/fontscale_provider.dart';
import 'package:provider/provider.dart';
import 'package:name_meaning/pages/MainPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => FontScaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontScale = context.watch<FontScaleProvider>().scale;

    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
      scaffoldBackgroundColor: Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.white)
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Name Meaning',
      theme: baseTheme,
      home: const MainPage(),

      // 🔥 BÜTÜN YAZILARI BURADAN BÜYÜT/KÜÇÜLT
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaleFactor: fontScale, // 0.8 - 1.0 - 1.2 - 1.5 vs
          ),
          child: child!,
        );
      },
    );
  }
}
