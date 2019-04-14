
import 'package:attendance_dashboard/src/sessions.dart';
/// class class
class Class {
  /// constructor
  Class(this._name, this._key);

  final String _name;
  /// class name
  String get name => _name;

  final String _key;
  /// class firebase key
  String get key => _key;

  final List<Session> _sessions = <Session>[];
  /// class's sessions
  List<Session> get sessions => _sessions;

  /// add a session
  void addSession(Session session) {
    _sessions.add(session);
  }
}