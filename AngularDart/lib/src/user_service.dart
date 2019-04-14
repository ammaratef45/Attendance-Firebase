import 'dart:async';
import 'dart:convert';

import 'package:attendance_dashboard/src/class.dart';
import 'package:attendance_dashboard/src/sessions.dart';
import 'package:http/http.dart';

/// Service of the user
class UserService {
  /// constructor
  UserService(this._http);

  //static const String _baseUrl = 'http://127.0.0.1:3000/';
  static const String _baseUrl = 'https://attendance-app-api.herokuapp.com/';
  static const String _infoUrl = '${_baseUrl}getInfo';
  static const String _downloadUrl = '${_baseUrl}downloadsheet';
  final Client _http;

  /// return the info from getinfo endpoint
  Future<List<Class>> getInfo(String token) async {
    try {
      final Response response = await _http.post(
        _infoUrl,
        headers:<String, String>{
          'x-token':token
        }
      );
      final Map<String, dynamic> classes =
        json.decode(response.body)['data']['classes'];
      final List<Class> classesList = <Class>[];
      for (String classkey in classes.keys) {
        final Class cl = Class(classes[classkey]['name'], classkey);
        final Map<String, dynamic> sessions = classes[classkey]['sessions'];
        if(sessions == null) {
          classesList.add(cl);
          continue;
        }
        for(String sessionKey in sessions.keys) {
          final String qrvalue = sessions[sessionKey]['qrval'];
          final String date = json.decode(qrvalue)['date'];
          final String location = json.decode(qrvalue)['address'];
          cl.addSession(Session(date, location, sessionKey));
        }
        classesList.add(cl);
      }
      return classesList;
    } catch (e) {
      rethrow;
    }
  }

  /// get the sheet for session or class
  Future<String> getSessionSheet(
    String token,
    {
      String classKey='0',
      String sessionKey='0'
    }
  ) async {
    try {
      final Map<String, String> headers = <String, String>{
        'x-token':token
      };
      final Map<String, dynamic> body = <String, dynamic>{};
      if(classKey!='0') {
        body['class'] = classKey;
      }
      if(sessionKey!='0') {
        body['session'] = sessionKey;
      }
      final Response response =
        await _http.post(_downloadUrl, headers:headers, body: body);
      return response.body;
    } catch (e) {
      rethrow;
    }
  }

}