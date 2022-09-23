import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_fl/helper_function.dart';
import 'package:weather_fl/weather_provider.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isChecked = false;

  /// initState, when state object first time call */
  @override
  void initState() {
    getTempStatus().then((value) {
      setState(() {
        _isChecked = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          Consumer<WeatherProvider>(
            builder: (context, provider, _) => SwitchListTile(
              activeColor: Colors.amberAccent,
                title: const Text('Show temperature in Fahrenheit'),
                subtitle: const Text('Default is Celsius'),
                value: _isChecked,
                onChanged: (value) async {
                  setState(() {
                    _isChecked = value;
                  });
                  await setTempStatus(value);
                  provider.reload();
                }
            ),
          )
        ],
      ),
    );
  }
}
