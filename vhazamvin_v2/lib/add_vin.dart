import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vhazamvin_v2/login.dart';
import 'package:vhazamvin_v2/wine_page.dart';
import 'package:http/http.dart' as http;

import 'custom_widgets.dart';
import 'service.dart';

class AddWineScreen extends StatefulWidget {
  AddWineScreen({Key? key}) : super(key: key);

  @override
  _AddWineScreenState createState() => _AddWineScreenState();
}

class _AddWineScreenState extends State<AddWineScreen> {
  final GlobalKey<FormState> _formWine = GlobalKey<FormState>();
  String? wineName;
  String? wineDomain;
  String? wineYear;

  Future<ApiResponse> addWine() async {
    var _apiResponse = ApiResponse();
    var url = Uri.parse('http://192.168.19.47:3211/api/addwine');
    var token = Service().token;
    var response = await http.post(url, body: {
      'wineName': wineName,
      'wineDomain': wineDomain,
      'wineYear': wineYear,
      'jwt': token
    });
    switch (response.statusCode) {
      case 200:
        var result = json.decode(response.body);
        _apiResponse.Data = result;
        break;
      case 400:
        _apiResponse.Data = 400;
        break;
      default:
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
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
        margin: const EdgeInsets.only(left: 35, right: 35),
        child: Form(
          key: _formWine,
          child: Column(
            children: <Widget>[
              Container(),
              TextFormField(
                onSaved: (newValue) => wineName = newValue,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "Entrez le nom du vin",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return ('Veuillez entrer le nom du vin');
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                onSaved: (newValue) => wineDomain = newValue,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "Entrez le nom du domaine du vin",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return ('Veuillez entrer le nom du doamine du vin');
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                onSaved: (newValue) => wineYear = newValue,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "Entrez l'annee du vin",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return ("Veuillez entrer l'annee du vin");
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_formWine.currentState!.validate()) {
                      _formWine.currentState!.save();
                      var tmp = await addWine();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return WinePage(request: tmp.Data);
                      }));
                    }
                  },
                  child: const Text("Add"))
            ],
          ),
        ),
      ),
    );
  }
}
