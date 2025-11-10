import 'package:flutter_secure_storage/flutter_secure_storage.dart';
final _storage = const FlutterSecureStorage();

Future<void> saveToken(String token) async => await _storage.write(key: 'api_token', value: token);
Future<String?> readToken() async => await _storage.read(key: 'api_token');
Future<void> deleteToken() async => await _storage.delete(key: 'api_token');
