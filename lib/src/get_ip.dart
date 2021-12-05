import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> getIp() async {
  var url = Uri.parse('https://api.myip.com');
  var response = await http.get(url);
  final data = jsonDecode(utf8.decode(response.bodyBytes));
  return data['ip'];
}
