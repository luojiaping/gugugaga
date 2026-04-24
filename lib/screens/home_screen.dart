import 'package:flutter/material.dart';
import '../services/alist_service.dart';
import '../widgets/file_list_tile.dart';

class HomeScreen extends StatefulWidget {
  final String serverUrl;
  final void Function(String url, String title) onPlay;

  const HomeScreen({
    super.key,
    required this.serverUrl,
    required this.onPlay,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AlistService _service = AlistService();
  List<AlistFile> _files = [];
  bool _loading = false;
  String _error = '';
  String _currentPath = '/';
  final List<String> _pathStack = [];

  @override
  void initState() {
    super.initState();
    if (widget.serverUrl.isNotEmpty) {
      _loadFiles(_currentPath);
    }
  }

  @override
  void didUpdateWidget(HomeScreen old) {
    super.didUpdateWidget(old);
    if (widget.serverUrl != old.serverUrl && widget.serverUrl.isNotEmpty) {
      _pathStack.clear();
      _currentPath = '/';
      _loadFiles(_currentPath);
    }
  }

  Future<void> _loadFiles(String path) async {
    if (widget.serverUrl.isEmpty) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final files = await _service.listFiles(widget.serverUrl, path);
      if (mounted) {
        setState(() {
          _files = files;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _onTileTap(AlistFile file) {
    if (file.isDir) {
      _pathStack.add(_currentPath);
      setState(() => _currentPath = file.path);
      _loadFiles(file.path);
    } else if (_isVideo(file.name)) {
      final playUrl = _service.getPlayUrl(widget.serverUrl, file.path);
      widget.onPlay(playUrl, file.name);
    } else if (_isAudio(file.name)) {
      final playUrl = _service.getPlayUrl(widget.serverUrl, file.path);
      widget.onPlay(playUrl, file.name);
    }
  }

  bool _isVideo(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', 'ts', 'mpd'].contains(ext);
  }

  bool _isAudio(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['mp3', 'flac', 'wav', 'aac', 'ogg', 'm4a', 'wma'].contains(ext);
  }

  void _goBack() {
    if (_pathStack.isNotEmpty) {
      final prev = _pathStack.removeLast();
      setState(() => _currentPath = prev);
      _loadFiles(prev);
    }
  }

  bool get _canGoBack => _pathStack.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (widget.serverUrl.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('请先在设置中配置服务器地址', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 顶部路径导航
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              if (_canGoBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBack,
                ),
              Expanded(
                child: Text(
                  _currentPath == '/' ? '根目录' : _currentPath,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadFiles(_currentPath),
              ),
            ],
          ),
        ),
        // 文件列表
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(_error, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(onPressed: () => _loadFiles(_currentPath), child: const Text('重试')),
                        ],
                      ),
                    )
                  : _files.isEmpty
                      ? Center(child: Text('空目录', style: Theme.of(context).textTheme.bodyLarge))
                      : RefreshIndicator(
                          onRefresh: () => _loadFiles(_currentPath),
                          child: ListView.builder(
                            itemCount: _files.length,
                            itemBuilder: (context, index) {
                              final file = _files[index];
                              return FileListTile(
                                file: file,
                                onTap: () => _onTileTap(file),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
