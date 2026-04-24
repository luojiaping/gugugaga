import 'dart:convert';
import 'package:http/http.dart' as http;

class AlistFile {
  final String name;
  final String path;
  final int size;
  final bool isDir;
  final String modified;

  AlistFile({
    required this.name,
    required this.path,
    required this.size,
    required this.isDir,
    required this.modified,
  });

  factory AlistFile.fromJson(Map<String, dynamic> json) {
    return AlistFile(
      name: json['name'] as String? ?? '',
      path: json['path'] ?? json['name'] ?? '',
      size: json['size'] as int? ?? 0,
      isDir: json['is_dir'] as bool? ?? false,
      modified: json['modified'] as String? ?? '',
    );
  }
}

class AlistService {
  String? _token;
  
  // 登录获取token
  Future<void> login(String serverUrl, String username, String password) async {
    final uri = Uri.parse('$serverUrl/api/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final code = body['code'];
    if (code != 200) {
      throw Exception('Alist登录错误: ${body["message"] ?? "未知错误"}');
    }

    _token = body['data']?['token'];
    if (_token == null || _token!.isEmpty) {
      throw Exception('Alist登录错误: 未获取到token');
    }
  }

  Future<List<AlistFile>> listFiles(String serverUrl, String path) async {
    final uri = Uri.parse('$serverUrl/api/fs/list');
    
    // 构建请求头
    final headers = {'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = _token!;
    }
    
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'path': path,
        'page': 1,
        'per_page': 200,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final code = body['code'];
    if (code != 200) {
      throw Exception('Alist错误: ${body["message"] ?? "未知错误"}');
    }

    final data = body['data']?['content'] as List? ?? [];
    return data.map((e) => AlistFile.fromJson(e as Map<String, dynamic>)).toList();
  }

  String getPlayUrl(String serverUrl, String path) {
    // Alist的直链地址
    return '$serverUrl/d$path';
  }

  // 清除token
  void logout() {
    _token = null;
  }
}