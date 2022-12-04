import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:vhazamvin_v2/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'custom_widgets.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _forRegister = GlobalKey<FormState>();
  String? user;
  String? password;

  Future<ApiResponse> register() async {
    var _apiResponse = ApiResponse();
    var url = Uri.parse('http://192.168.19.47:3211/signup');
    //var url = Uri.parse('http://127.0.0.1:49227/signup');
    var response = await http.post(url, body: {
      'ident': user,
      'passwd': password,
    });
    switch (response.statusCode) {
      case 200:
        var jwt = response.body;
        FlutterSecureStorage().write(key: "jwt", value: jwt);
        _apiResponse.Data = jwt;
        break;
      case 401:
        _apiResponse.ApiError = ApiError.fromJson(json.decode(response.body));
        break;
      default:
        _apiResponse.ApiError = ApiError.fromJson(json.decode(response.body));
        break;
    }
    return _apiResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWine(),
      drawer: DrawerWine(),
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
        margin: const EdgeInsets.only(left: 35, right: 35),
        child: Form(
          key: _forRegister,
          child: Column(
            children: <Widget>[
              Container(),
              TextFormField(
                onSaved: (newValue) => user = newValue,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: "Entre votre identifiant",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return ('Veuillez entrer votre identifiant');
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 40,
              ),
              TextFormField(
                onSaved: (newValue) {
                  var bytes = utf8.encode(newValue ?? '');
                  password = sha256.convert(bytes).toString();
                },
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: "Entre votre mot de passe",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return ('Veuillez entrer votre mot de passe');
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_forRegister.currentState!.validate()) {
                      _forRegister.currentState!.save();
                      var tmp = await register();
                      print("bah non 2");
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return HomePage(token: tmp.Data);
                      }));
                    }
                  },
                  child: const Text("Register"))
            ],
          ),
        ),
      ),
    );
  }
}
