import 'dart:convert';
import 'package:http/http.dart' as http;

class AlistFile {
  final String name;
  final String path;
  final int size;
  final bool isDir;
  final String modified;
  final String sign;

  AlistFile({
    required this.name,
    required this.path,
    required this.size,
    required this.isDir,
    required this.modified,
    this.sign = '',
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

  /// 自动尝试HTTPS，如果HTTP连接失败则切换
  Future<http.Response> _safeRequest(Uri uri, {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await http.post(uri, headers: headers, body: body);
      return response;
    } catch (e) {
      // 如果是HTTP连接失败，尝试HTTPS
      if (uri.scheme == 'http') {
        final httpsUri = Uri.parse(uri.toString().replaceFirst('http://', 'https://'));
        try {
          final response = await http.post(httpsUri, headers: headers, body: body);
          return response;
        } catch (_) {
          // HTTPS也失败，抛出原始错误
          rethrow;
        }
      }
      rethrow;
    }
  }

  // 登录获取token
  Future<void> login(String serverUrl, String username, String password) async {
    serverUrl = _normalizeUrl(serverUrl);
    final uri = Uri.parse('$serverUrl/api/auth/login');
    final response = await _safeRequest(
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
    
    final response = await _safeRequest(
      uri,
      headers: headers,
      body: jsonEncode({
        'path': dirPath,
        'password': '',
        'page': 1,
        'per_page': 200,
        'refresh': false,
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
        sign: item['sign'] as String? ?? '',
      );
    }).toList();
  }

  /// 获取文件/目录详情（包含raw_url直链）
  Future<Map<String, dynamic>?> getFileInfo(String serverUrl, String path) async {
    serverUrl = _normalizeUrl(serverUrl);
    final uri = Uri.parse('$serverUrl/api/fs/get');
    
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = _token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = token;
    }
    
    final response = await _safeRequest(
      uri,
      headers: headers,
      body: jsonEncode({
        'path': path,
        'password': '',
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

    return body['data'] as Map<String, dynamic>?;
  }

  /// 获取播放URL，优先使用/api/fs/get获取raw_url
  Future<String> getPlayUrl(String serverUrl, String path, {String sign = ''}) async {
    serverUrl = _normalizeUrl(serverUrl);
    
    // 尝试通过/api/fs/get获取真实直链
    try {
      final info = await getFileInfo(serverUrl, path);
      if (info != null) {
        final rawUrl = info['raw_url'] as String?;
        if (rawUrl != null && rawUrl.isNotEmpty) {
          return rawUrl;
        }
      }
    } catch (_) {
      // /api/fs/get失败，回退到直接拼接
    }
    
    // 回退方案：拼接Alist直链地址，附加sign
    String url = '$serverUrl/d$path';
    if (sign.isNotEmpty) {
      url += '?sign=$sign';
    }
    return url;
  }

  /// 同步获取播放URL（不调用API，直接拼接直链）
  String getPlayUrlSync(String serverUrl, String path, {String sign = ''}) {
    serverUrl = _normalizeUrl(serverUrl);
    String url = '$serverUrl/d$path';
    if (sign.isNotEmpty) {
      url += '?sign=$sign';
    }
    return url;
  }

  // 清除token
  void logout() {
    _token = null;
  }
}