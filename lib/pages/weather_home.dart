import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:weather_fl/constant.dart';
import 'package:weather_fl/helper_function.dart';
import 'package:weather_fl/weather_provider.dart';

class WeatherHome extends StatefulWidget {
  static const String routeName = '/';

  const WeatherHome({Key? key}) : super(key: key);

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  late WeatherProvider _provider;
  bool _isInit = true;


  @override
  void didChangeDependencies() {
    if (_isInit) {
      _provider = Provider.of<WeatherProvider>(context);
      _getPosition();
      _isInit = false;
    }
  }

  _getPosition() {
    determinePosition().then((position) {
      setState(() {
        final latitude = position.latitude;
        final longitude = position.longitude;
        _provider.setNewLatLon(latitude, longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text('Weather App'),
        actions: [

        ],
      ),
      body: _provider.hasDataLoaded ? ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _currentSection(),
          SizedBox(height: 30,),
          _forecastSection(),
        ],
      ) : Center(child: const Text('Please wait...', style: textDefaultStyle,),),
    );
  }

  Widget _currentSection() {
    return Column(
      children: [
        Text(getFormattedData(_provider.currentResponse!.dt!, 'MMM dd, yyyy hh:mm a'), style: textDateStyle,),
        Text('${_provider.currentResponse!.name}, ${_provider.currentResponse!.sys!.country}', style: textAddressStyle,),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${_provider.currentResponse!.main!.temp!.round()}\u00B0', style: textTempBig80Style,),
              SizedBox(width: 10,),
              Text('${_provider.currentResponse!.main!.tempMax!.round()}/${_provider.currentResponse!.main!.tempMin!.round()}\u00B0', style: textTempNormalStyle,),
            ],
          ),
        ),
        Text('Feels Like ${_provider.currentResponse!.main!.feelsLike!.round()}\u00B0', style: textTempNormalStyle,),
        Image.network('$iconPrefix${_provider.currentResponse!.weather!.first.icon}$iconSuffix', width: 80, height: 80,),
        Text(_provider.currentResponse!.weather!.first.description!, style: textAddressStyle,),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap( /** Like Row but extra feature automatically break line when content so much in single line */
            children: [
              Text('Humidity ', style: textDefaultStylewhite70,),
              Text('${_provider.currentResponse!.main!.humidity}%', style: textDefaultStyle,),
              Text(' Pressure ', style: textDefaultStylewhite70,),
              Text('${_provider.currentResponse!.main!.pressure}hPa', style: textDefaultStyle,),
              Text(' Speed ', style: textDefaultStylewhite70,),
              Text('${_provider.currentResponse!.wind!.speed}m/s', style: textDefaultStyle,),
              Text(' Visibility ', style: textDefaultStylewhite70,),
              Text('${_provider.currentResponse!.visibility}km', style: textDefaultStyle,),
            ],
          ),
        )
      ],
    );
  }

  Widget _forecastSection() {
    return Container( /** Why container? Because of using listview horizontal and also for scrolling that's why we need height not width */
      padding: const EdgeInsets.all(8.0),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _provider.forecastResponse!.list!.length,
        itemBuilder: (context, index) {
          final item = _provider.forecastResponse!.list![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(getFormattedData(item.dt!, 'EEE HH:mm'), style: textDateStyle,),
                Image.network('$iconPrefix${item.weather!.first.icon}$iconSuffix', width: 40, height: 40,),
                Text(item.weather!.first.description!, style: textDefaultStyle,),
                Text('${item.main!.tempMax!.round()}/${item.main!.tempMin!.round()}\u00B0', style: textTempNormalStyle,),
              ],
            ),
          );
        },
      ),
    );
  }

}
