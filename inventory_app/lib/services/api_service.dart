import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';
import 'dart:io';

class ApiService {
  final Dio dio;
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // ganti kalau pakai ngrok / IP host

  ApiService(): dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<void> _setAuthHeader() async {
    final token = await readToken();
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  // Auth
  Future<Map<String,dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    final r = await dio.post('/register', data: {
      'name': name, 'email': email, 'password': password, 'password_confirmation': passwordConfirmation
    });
    return r.data;
  }

  Future<Map<String,dynamic>> login(String email, String password) async {
    final r = await dio.post('/login', data: {'email': email, 'password': password});
    return r.data;
  }

  Future<Response> fetchProducts({int page = 1, String? q}) async {
    await _setAuthHeader();
    return dio.get('/products', queryParameters: {'page': page, 'q': q});
  }

  Future<Response> createProduct(Map<String,dynamic> body, [String? imagePath]) async {
    await _setAuthHeader();
    FormData form = FormData.fromMap(body);
    if (imagePath != null) {
      form.files.add(MapEntry('image', await MultipartFile.fromFile(imagePath)));
    }
    return dio.post('/products', data: form);
  }

  Future<Response> updateProduct(int id, Map<String,dynamic> body, [String? imagePath]) async {
    await _setAuthHeader();
    FormData form = FormData.fromMap(body);
    if (imagePath != null) {
      form.files.add(MapEntry('image', await MultipartFile.fromFile(imagePath)));
    }
    // Laravel expects PUT, but multipart form + PUT not supported by some clients; use _method
    return dio.post('/products/$id?_method=PUT', data: form);
  }

  Future<Response> deleteProduct(int id) async {
    await _setAuthHeader();
    return dio.delete('/products/$id');
  }

  Future<Response> logout() async {
    await _setAuthHeader();
    return dio.post('/logout');
  }
}
