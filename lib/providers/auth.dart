import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer; // cancel ongoing timer

  /* When a user or device signs in using Firebase Authentication, Firebase
  creates a corresponding ID token that uniquely identifies them and grants
  them access to several resources, such as Realtime Database and
  Cloud Storage.*/

  String get userId {
    return _userId;
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCipFRRCTwnhUfy5vjQNGbeePcO02KaIqY';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true,},
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      autoLogOut();
      notifyListeners();
      final preferences = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String()
        },
      );
      preferences.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> singUp(String email, String password) async {
    return authenticate(email, password, 'signUp');

    /* const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCipFRRCTwnhUfy5vjQNGbeePcO02KaIqY';
    final response = await http.post(
      url,
      body: json.encode(
        {'email': email, 'password': password, 'returnSecureToken': true},
      ),
    ); */
    //print(json.decode(response.body));
  }

  Future<void> logIn(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');

    /* const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCipFRRCTwnhUfy5vjQNGbeePcO02KaIqY';
    final response = await http.post(url,
        body: json.encode(
            {'email': email, 'password': password, 'returnSecureToken': true})); */
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  bool get isAuth {
    return _token != null;
  }

  Future<void> logOut() async{
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

  //automatically logout after some time
  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }

  Future<bool> tryAutoLogin() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(preferences.get('userData')) as Map<String, Object>;
    final expiryDate= DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())){
      return false;
    }
    // re-initializing
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogOut();
    return true;

  }
}
