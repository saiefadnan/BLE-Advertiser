class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  bool started = false;
  String status = "Not advertising";
}

final bleservice = BleService();
