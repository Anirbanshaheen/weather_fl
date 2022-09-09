import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_fl/pages/settings_page.dart';
import 'package:weather_fl/pages/weather_home.dart';
import 'package:weather_fl/weather_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => WeatherProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Merriweather',
        primarySwatch: Colors.blue,
      ),
      initialRoute: WeatherHome.routeName,
      routes: {
        WeatherHome.routeName: (context) => WeatherHome(),
        SettingsPage.routeName: (context) => SettingsPage(),
      },
    );
  }
}
