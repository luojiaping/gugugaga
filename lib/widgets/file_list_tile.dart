import 'package:flutter/material.dart';
import '../services/alist_service.dart';

class FileListTile extends StatelessWidget {
  final AlistFile file;
  final VoidCallback onTap;

  const FileListTile({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = file.isDir
        ? Icons.folder
        : _fileIcon(file.name);
    final color = file.isDir
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(file.name),
      subtitle: file.isDir ? null : Text(_formatSize(file.size)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', 'ts', 'mpd'].contains(ext)) {
      return Icons.play_circle;
    }
    if (['mp3', 'flac', 'wav', 'aac', 'ogg', 'm4a', 'wma'].contains(ext)) {
      return Icons.audiotrack;
    }
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Icons.image;
    }
    if (['srt', 'ass', 'vtt', 'ssa'].contains(ext)) {
      return Icons.subtitles;
    }
    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
