
import 'package:attendance_dashboard/src/sessions.dart';

class Class {
  final String _name;
  String get name => _name;
  Class(this._name);

  List<Session> _sessions = List();
  List<Session> get sessions => _sessions;

  void addSession(Session session) {
    _sessions.add(session);
  }
}