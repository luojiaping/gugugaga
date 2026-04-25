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
}

class AlistService {
  String? _token;

  /// 标准化服务器URL，去除尾部斜杠
  String _normalizeUrl(String url) {
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  // 登录获取token
  Future<void> login(String serverUrl, String username, String password) async {
    serverUrl = _normalizeUrl(serverUrl);
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
    final token = _token;
    if (token == null || token.isEmpty) {
      throw Exception('Alist登录错误: 未获取到token');
    }
  }

  Future<List<AlistFile>> listFiles(String serverUrl, String dirPath) async {
    serverUrl = _normalizeUrl(serverUrl);
    final uri = Uri.parse('$serverUrl/api/fs/list');
    
    // 构建请求头
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = _token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = token;
    }
    
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'path': dirPath,
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
    return data.map((e) {
      final item = e as Map<String, dynamic>;
      // Alist /api/fs/list 不返回path字段，需要手动拼接完整路径
      final name = item['name'] as String? ?? '';
      final fullPath = dirPath == '/' ? '/$name' : '$dirPath/$name';
      return AlistFile(
        name: name,
        path: fullPath,
        size: item['size'] as int? ?? 0,
        isDir: item['is_dir'] as bool? ?? false,
        modified: item['modified'] as String? ?? '',
      );
    }).toList();
  }

  String getPlayUrl(String serverUrl, String path) {
    serverUrl = _normalizeUrl(serverUrl);
    // Alist的直链地址
    return '$serverUrl/d$path';
  }

  // 清除token
  void logout() {
    _token = null;
  }
}
