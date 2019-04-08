import 'dart:async';
import 'dart:convert';

import 'package:attendance_dashboard/src/class.dart';
import 'package:attendance_dashboard/src/sessions.dart';
import 'package:http/http.dart';

class UserService {
  static const _infoUrl = 'https://attendance-app-api.herokuapp.com/getInfo';
  //static const _infoUrl = 'http://127.0.0.1:3000/getInfo';
  final Client _http;

  UserService(this._http);

  Future<List<Class>> getInfo(String token) async {
    try {
      final response = await _http.post(_infoUrl, headers:{
        'x-token':token
      });
      Map classes = json.decode(response.body)['data']['classes'];
      List<Class> classesList = List();
      for (String classkey in classes.keys) {
        Class cl = Class(classes[classkey]["name"]);
        Map sessions = classes[classkey]["sessions"];
        for(String sessionKey in sessions.keys) {
          String qrvalue = sessions[sessionKey]['qrval'];
          String date = json.decode(qrvalue)['date'];
          String location = json.decode(qrvalue)['address'];
          cl.addSession(Session(date, location));
        }
        classesList.add(cl);
      }
      return classesList;
    } catch (e) {
      throw e.toString();
    }
  }

}