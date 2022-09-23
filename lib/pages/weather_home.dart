import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:weather_fl/constant.dart';
import 'package:weather_fl/helper_function.dart';
import 'package:weather_fl/pages/settings_page.dart';
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
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _provider = Provider.of<WeatherProvider>(context);
      isConnectedToInternet().then((value) {
        if (value) {
          _getPosition();
        } else {
          messageShowing();
        }
      });

      subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
          _getPosition();
        } else {
          messageShowing();
        }
      });

      _isInit = false;
    }
  }

  void messageShowing() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No Internet available!')));
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
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () { _getPosition(); },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              /** Built in search options from Flutter */
              final result = await showSearch(context: context, delegate: _CitySearchDelegate());
              if (result != null) {
                _convertCityToLatLong(result);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SettingsPage.routeName),
          )
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

  void _convertCityToLatLong(String result) async {
    try {
      final locationList = await locationFromAddress(result);
      if (locationList.isNotEmpty) {
        final location = locationList.first;
        _provider.setNewLatLon(location.latitude, location.longitude);
      }
    }catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid City')));
      throw error;
    }
  }

}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
        onPressed: () {
          /** When user type a string but not search it then we fetch that value with us */
          close(context, query);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.search),
      title: Text(query),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    /** Logic If query is empty then load cities list
     *  Otherwise loop all cities.
     * */
    final filteredList = query.isEmpty ? cities :
        cities.where((city) => city.toLowerCase().contains(query.toLowerCase()));
    return ListView(
      children: filteredList.map((city) => ListTile(
        onTap: () {
          close(context, city);
        },
        title: Text(city),
      )).toList(),
    );
  }

}
