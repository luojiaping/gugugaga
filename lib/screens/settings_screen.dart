import 'dart:async';

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String serverUrl;
  final Future<void> Function(String url) onServerUrlChanged;
  final Future<void> Function(String username) onUsernameChanged;
  final Future<void> Function(String password) onPasswordChanged;
  final Future<void> Function() onThemeToggled;
  final bool isDarkMode;
  final String username;
  final String password;

  const SettingsScreen({
    super.key,
    required this.serverUrl,
    required this.onServerUrlChanged,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onThemeToggled,
    required this.isDarkMode,
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('设置', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        // 服务器地址
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alist 服务器', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('当前地址: ${serverUrl.isEmpty ? "未配置" : serverUrl}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                _ServerUrlField(onSubmitted: onServerUrlChanged),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 登录认证
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('登录认证', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('当前用户: ${username.isEmpty ? "未登录" : username}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                _LoginField(
                  username: username,
                  password: password,
                  onUsernameChanged: onUsernameChanged,
                  onPasswordChanged: onPasswordChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 主题切换
        Card(
          child: SwitchListTile(
            title: const Text('深色模式'),
            subtitle: Text(isDarkMode ? '当前：深色' : '当前：浅色'),
            value: isDarkMode,
            onChanged: (_) => unawaited(onThemeToggled()),
          ),
        ),
        const SizedBox(height: 16),
        // 关于
        Card(
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            subtitle: const Text('咕咕嘎嘎 v1.0.0\n基于 Flutter + Alist 的影视播放App'),
          ),
        ),
      ],
    );
  }
}

class _ServerUrlField extends StatefulWidget {
  final Future<void> Function(String url) onSubmitted;
  const _ServerUrlField({required this.onSubmitted});

  @override
  State<_ServerUrlField> createState() => _ServerUrlFieldState();
}

class _ServerUrlFieldState extends State<_ServerUrlField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '输入Alist服务器地址',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => unawaited(widget.onSubmitted(value)),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => unawaited(widget.onSubmitted(_controller.text)),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _LoginField extends StatefulWidget {
  final String username;
  final String password;
  final Future<void> Function(String username) onUsernameChanged;
  final Future<void> Function(String password) onPasswordChanged;

  const _LoginField({
    required this.username,
    required this.password,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
  });

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
    _passwordController.text = widget.password;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: '用户名',
            hintText: '输入Alist用户名',
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: '密码',
            hintText: '输入Alist密码',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {
                  unawaited(widget.onUsernameChanged(_usernameController.text));
                  unawaited(widget.onPasswordChanged(_passwordController.text));
                },
                child: const Text('保存登录信息'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
