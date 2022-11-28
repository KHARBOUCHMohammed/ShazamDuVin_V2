// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vhazamvin_v2/home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:google_ml_vision/google_ml_vision.dart';

import 'second_screen.dart';
import 'login.dart';
import 'custom_widgets.dart';
import 'take_picture_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Test App",
      home: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  Future<String> get jwtOrEmpty async {
    String? jwt = await FlutterSecureStorage().read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
          future: jwtOrEmpty,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data != "" && snapshot.data != null) {
              var token = snapshot.data.toString();
              var str = token.split(".");
              if (str.length != 3) return HomePage();
              if (JwtDecoder.isExpired(token)) {
                Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
                return HomePage(
                  token: token,
                ); //TODO: modifier par un appel à homepage avec le token
              } else {
                return HomePage();
              }
            } else {
              return HomePage();
            }
          }),
    );
  }
}
