List<Counter> counters = [];

class Counter {
  final int _id;
  final String _name;
  final List<DateTime> _dateHistory;

  Counter(this._id, this._name, this._dateHistory);

  int get id {
    return _id;
  }

  String get name {
    return _name;
  }

  List<DateTime> get dateHistory {
    return _dateHistory;
  }

  Map<String, dynamic> toMap() {
    return {'id': _id, 'name': _name};
  }
}
