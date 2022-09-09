import 'dart:ui';

import 'package:flutter/material.dart';

const String weatherApiKey = "238f7be47691e1e72c7d575613306ace";

const String iconPrefix = 'https://openweathermap.org/img/wn/';
const String iconSuffix = '@2x.png';

const textTempBig80Style = TextStyle(
  fontSize: 80,
  fontWeight: FontWeight.bold,
  color: Colors.white
);

const textTempNormalStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70
);

const textDateStyle = TextStyle(
    fontSize: 16,
    letterSpacing: 1.2,
    color: Colors.white70
);

const textAddressStyle = TextStyle(
    fontSize: 18,
    letterSpacing: 1.2,
    color: Colors.white70
);

const textDefaultStylewhite70 = TextStyle(
    fontSize: 14,
    letterSpacing: 1.0,
    color: Colors.white70
);

const textDefaultStyle = TextStyle(
    fontSize: 14,
    letterSpacing: 1.0,
    color: Colors.white
);