/// Session class
class Session {
  /// constructor
  Session(this._date, this._location, this._key);

  final String _date;
  final String _location;
  final String _key;

  /// date
  String get date => _date;
  /// location
  String get location => _location;
  /// firebase key
  String get key => _key;
}