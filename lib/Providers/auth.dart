import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_shop/Models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != '') {
      return _token;
    }
    return null;
  }

  String get userId => _userId;

  bool get isAuth => token != '';

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    // https://firebase.google.com/docs/reference/rest/auth#section-create-email-password

    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB28QSng_SKaeigan0hLwYUnC0OFD_b9tc';
    try {
      final res = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(res.body);
      if (responseData['error'] != null)
        throw HttpException(responseData['error']['message']);

      _token = responseData['idToken'];

      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogOut();
      notifyListeners();

      // add userData info to SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });

      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final Map<String, Object> extractedData =
        json.decode(prefs.getString('userdata')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = '';
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogOut() {
    _token = '';
    _userId = null;
    // _expiryDate = null;
    if (_authTimer != null) _authTimer.cancel();

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
