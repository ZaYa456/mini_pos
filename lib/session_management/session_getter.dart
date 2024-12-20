//This file is to get the session id from the shared preferences package

import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getSessionId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('sessionId');
}
