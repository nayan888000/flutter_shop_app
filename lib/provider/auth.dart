import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
    
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId{
    return _userId;
  }

  Future<void> _auth1(String email, String password, String type) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$type?key=AIzaSyDa7tXW2RCWIPs2KbhaqCY5kIYRqsU_jxM';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
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
          seconds: int.parse(
            responseData['erpiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs= await SharedPreferences.getInstance();
      final userData =json.encode({
        'token':_token,
        'userId':_userId,
        'expiryDate':_expiryDate.toIso8601String(),
      },);
      prefs.setString('userData',userData);
    } catch (error) {
      throw (error);
    }
  }

  Future<void> signup(String email, String password) async {
    return _auth1(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    const url='https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDa7tXW2RCWIPs2KbhaqCY5kIYRqsU_jxM';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
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
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
     _autoLogout();
      notifyListeners();
      final prefs= await SharedPreferences.getInstance();
      final userData =json.encode({
        'token':_token,
        'userId':_userId,
        'expiryDate':_expiryDate.toIso8601String(),
      },);
      prefs.setString('userData',userData);
    
    } catch (error) {
      throw (error);
    }
  }

  Future<bool> tryAutoLogin() async{
    final prefs= await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extraction =json.decode(prefs.getString('userData'))as Map<String,Object>;
    final expiryDate = DateTime.parse(extraction['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token=extraction['token'];
    _userId=extraction['userId'];
    _expiryDate=expiryDate;
    notifyListeners();
    _autoLogout();
    return true;  
  }

  Future<void> logout() async{
    _token=null;
    _userId=null;
    _expiryDate=null;
      if(_authTimer!=null){
      _authTimer.cancel();
      _authTimer=null;
    }
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();

  }

  void _autoLogout(){
    
    if(_authTimer!=null){
      _authTimer.cancel();
    }
    final timeToExpiry=_expiryDate.difference(DateTime.now()).inSeconds;
    
    Timer(Duration(seconds:timeToExpiry),logout);
  }
}
 