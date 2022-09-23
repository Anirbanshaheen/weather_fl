import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:weather_fl/constant.dart';
import 'package:weather_fl/helper_function.dart';
import 'package:weather_fl/models/current_response.dart';
import 'package:weather_fl/models/forecast_response.dart';

class WeatherProvider with ChangeNotifier {
  double latitude = 0.0;
  double longitude = 0.0;

  CurrentResponse? currentResponse;
  ForecastResponse? forecastResponse;

  void setNewLatLon(double lat, double lon) {
    latitude = lat;
    longitude = lon;
    _getData();
  }

  bool get hasDataLoaded => currentResponse != null && forecastResponse != null;

  void reload() {
    _getData();
  }

  void _getData() {
    _getCurrentData();
    _getForecastData();
  }

  void _getCurrentData() async {
    final unit = await tempUnit;
    final url = "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApiKey";
    try {
      final response = await get(Uri.parse(url));
      if (response.statusCode == 200) {
        final map = json.decode(response.body); // json -> map -> class
        currentResponse = CurrentResponse.fromJson(map);
        print('current: ${currentResponse!.main!.temp}');
        notifyListeners();
      }
    } catch(error) {
      print(error.toString());
      throw error;
    }
  }

  void _getForecastData() async {
    final unit = await tempUnit;
    final url = "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weatherApiKey";
    try {
      final response = await get(Uri.parse(url));
      if (response.statusCode == 200) {
        final map = json.decode(response.body); // json -> map -> class
        forecastResponse = ForecastResponse.fromJson(map);
        print('forecast: ${forecastResponse!.list!.length}');
        notifyListeners();
      }
    } catch(error) {
      print(error.toString());
      throw error;
    }
  }

  Future<String> get tempUnit async {
    return await getTempStatus() ? 'imperial' : 'metric';
  }

}