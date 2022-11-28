import 'package:jwt_decoder/jwt_decoder.dart';

class Service {
  static final Service _instance = Service._internal();

  factory Service() => _instance;

  Service._internal() {}

  dynamic _token = {};
  String _user = "inconnu";
  bool _admin = false;

  dynamic get token => _token;
  String get user => _user;
  bool get admin => _admin;

  set token(dynamic value) {
    _token = value;
    if (value != "") {
      var tmp = JwtDecoder.decode(value);
      _user = tmp['ident'];
      _admin = tmp['admin'];
    }
  }

  void reset() {
    _token = {};
    _user = "inconnu";
    _admin = false;
  }

  bool isConnected() {
    return user != "inconnu" ? true : false;
  }
}
