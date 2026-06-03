import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final aiConfigServiceProvider =
    Provider<AiConfigService>((ref) {
  return AiConfigService(
      ref.watch(secureStorageProvider));
});

class AiConfigService {
  final FlutterSecureStorage _storage;
  static const _keyApiKey = 'openai_api_key';

  AiConfigService(this._storage);

  Future<String?> getApiKey() =>
      _storage.read(key: _keyApiKey);

  Future<void> saveApiKey(String key) =>
      _storage.write(key: _keyApiKey, value: key);

  Future<void> deleteApiKey() =>
      _storage.delete(key: _keyApiKey);

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}
