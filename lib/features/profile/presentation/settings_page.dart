import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  bool _hasSavedKey = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key =
        await _storage.read(key: 'openai_api_key');
    if (key != null && key.isNotEmpty) {
      _apiKeyController.text = key;
      _hasSavedKey = true;
    }
  }

  Future<void> _saveKey() async {
    setState(() => _loading = true);
    await _storage.write(
        key: 'openai_api_key',
        value: _apiKeyController.text);
    setState(() {
      _loading = false;
      _hasSavedKey = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('API Key 已保存 ✓')),
      );
    }
  }

  Future<void> _deleteKey() async {
    await _storage.delete(key: 'openai_api_key');
    _apiKeyController.clear();
    setState(() => _hasSavedKey = false);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'AI 设置',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '填入你的 OpenAI API Key 以启用 AI 日记和智能推荐。不填也能使用全部基础功能。',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFb8a99a)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'sk-...',
                suffixIcon: _hasSavedKey
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            size: 18),
                        onPressed: _deleteKey,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _loading ? null : _saveKey,
                child: Text(_hasSavedKey
                    ? '更新 Key'
                    : '保存 Key'),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '通用设置',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('关于 MoodFlow',
                  style: TextStyle(fontSize: 14)),
              subtitle: const Text('v1.0.0',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFFb8a99a))),
              trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFd0c8bc)),
            ),
          ],
        ),
      ),
    );
  }
}
