import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../providers/publication_provider.dart';
import '../services/openalex_config.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/openalex_config_widgets.dart';

/// Configure and test the OpenAlex API key.
class OpenAlexConfigScreen extends StatefulWidget {
  const OpenAlexConfigScreen({super.key});

  @override
  State<OpenAlexConfigScreen> createState() => _OpenAlexConfigScreenState();
}

class _OpenAlexConfigScreenState extends State<OpenAlexConfigScreen> {
  final _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _saving = false;
  bool _testing = false;
  OpenAlexConnectionState _connectionState = OpenAlexConnectionState.unknown;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapStatus());
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapStatus() async {
    final config = context.read<OpenAlexConfig>();
    if (!config.hasKey) {
      setState(() => _connectionState = OpenAlexConnectionState.notConfigured);
      return;
    }
    setState(() => _connectionState = OpenAlexConnectionState.success);
  }

  Future<void> _testConnection() async {
    final s = context.stringsOf;
    setState(() {
      _testing = true;
      _connectionState = OpenAlexConnectionState.testing;
      _connectionError = null;
    });

    try {
      final provider = context.read<PublicationProvider>();
      final key = _keyController.text.trim();
      if (key.isNotEmpty) {
        await provider.saveOpenAlexApiKey(key);
      }

      final ok = await provider.testOpenAlexConnection();
      if (!mounted) return;

      setState(() {
        _connectionState = ok
            ? OpenAlexConnectionState.success
            : OpenAlexConnectionState.failed;
        _connectionError =
            ok ? null : s.openAlexNoResponse;
        if (ok && key.isNotEmpty) _keyController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _connectionState = OpenAlexConnectionState.failed;
        _connectionError =
            e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _saveKey() async {
    final s = context.stringsOf;
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.enterApiKeyToSave)),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final provider = context.read<PublicationProvider>();
      await provider.saveOpenAlexApiKey(key);
      if (!mounted) return;

      _keyController.clear();
      setState(() => _connectionState = OpenAlexConnectionState.success);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.apiKeySaved)),
      );

      await provider.refreshCurrentAnalysis();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<OpenAlexConfig>();
    final s = context.strings;
    final busy = _saving || _testing;
    final hint = config.hasKey && _keyController.text.isEmpty
        ? config.maskedApiKey
        : s.pasteApiKey;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.openAlexConfig,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const OpenAlexInfoCard(),
          const SizedBox(height: 20),
          PremiumCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.apiKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _keyController,
                  obscureText: _obscureKey,
                  enabled: !busy,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: config.hasKey && _keyController.text.isEmpty
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: busy
                          ? null
                          : () => setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.keepApiKeyPrivate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OpenAlexConnectionCard(
            state: _connectionState,
            errorMessage: _connectionError,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: busy ? null : _testConnection,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _testing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      s.testConnection,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: busy ? null : _saveKey,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      s.saveApiKey,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              s.academicDataFromOpenAlex,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
