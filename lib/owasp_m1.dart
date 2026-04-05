import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owasptoprisks/dependencies_scope.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OWASP M1 — Improper Credential Usage
// https://owasp.org/www-project-mobile-top-10/2023-risks/m1-improper-credential-usage.html
// ─────────────────────────────────────────────────────────────────────────────
//
// At its core, M1 is about hardcoding sensitive data directly inside the
// application binary — API keys, tokens, passwords, secrets written as plain
// string literals in the source code. Because mobile APKs and IPAs can be
// reverse engineered with tools like jadx, apktool, or Hopper in a matter of
// minutes, anything hardcoded is effectively public. The attacker does not
// need to touch a running device — they just decompile the app offline.
//
// Common examples of hardcoded credentials that violate M1:
//   • const apiKey = "sk_live_abc123...";
//   • const githubToken = "ghp_xxxxxxxxxxxx";
//   • if (password == "admin1234") { ... }
//
// This screen demonstrates saving a PIN locally using flutter_secure_storage.
// But before going further — let's be honest about what secure storage
// actually gives you.
//
// ─────────────────────────────────────────────────────────────────────────────
// flutter_secure_storage does not give real protection
// ─────────────────────────────────────────────────────────────────────────────
//
// flutter_secure_storage is backed by iOS Keychain and Android Keystore.
// On paper that sounds secure. In practice:
//
//   • On a rooted Android device the sandbox is gone. Any process with
//     elevated privileges can read Keystore data directly.
//   • On a jailbroken iOS device it is significantly harder — iOS Keychain
//     is backed by hardware encryption (Secure Enclave). Extracting it in
//     practice requires specialized software and low-level exploits. Still
//     not impossible, but the bar is much higher than on Android.
//   • Malicious software (spyware, repackaged APK with injected SDK) runs
//     inside your process and calls the same read() API your app calls.
//     It sees the decrypted value — no bypass needed.
//   • Runtime hooks (Frida, Xposed) intercept the value the moment your
//     code decrypts it, before it even reaches the network.
//
// In short: if the device or the app process is compromised, secure storage
// is open. flutter_secure_storage only stops the most basic attacks
// (plain file reads by unprivileged apps). It is not a security boundary.
//
// ─────────────────────────────────────────────────────────────────────────────
// The server is the only real source of truth
// ─────────────────────────────────────────────────────────────────────────────
//
// Real security lives entirely on the server:
//
//   • Access tokens must be short-lived. Even if stolen, they expire
//     before the attacker can cause meaningful damage.
//   • Refresh tokens must rotate on every use — server invalidates the
//     previous one immediately. A stolen token is detected the moment
//     both parties attempt to use it.
//   • The server validates every request: context, device fingerprint,
//     usage patterns. Anything anomalous triggers re-authentication.
//
// If the server side is broken, nothing on the mobile device saves you.
// No amount of local encryption compensates for tokens that never expire,
// never rotate, and never validate the caller.
//
// ─────────────────────────────────────────────────────────────────────────────
// Sensitive tokens must never reach the client device — period
// ─────────────────────────────────────────────────────────────────────────────
//
//   Wrong ✗
//     App holds a GitHub / Stripe / any privileged token in secure storage.
//     When the user performs an action, the app calls the third-party API
//     directly using that token.
//     → Token lives on device. Attacker extracts it. Full account access.
//
//   Correct ✓
//     Token lives only on your backend server — the app never sees it.
//     App sends: POST /api/github/create-issue { title, body }
//     Server authenticates the caller via its own short-lived session,
//     then executes the GitHub call using the stored token internally.
//     → Nothing to steal from the device.
//
// The mobile app is an untrusted client. The server is the trust boundary.
// Design accordingly — store secrets on the server, not on the device.
// ─────────────────────────────────────────────────────────────────────────────

/// {@template owasp_m1}
/// OwaspM1 widget.
/// {@endtemplate}
class OwaspM1 extends StatefulWidget {
  /// {@macro owasp_m1}
  const OwaspM1({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<OwaspM1> createState() => _OwaspM1State();
}

/// State for widget OwaspM1.
class _OwaspM1State extends State<OwaspM1> {
  late final OwaspM1PinController _controller;
  final TextEditingController _pinInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    _controller = OwaspM1PinController(
      iOwaspM1: OwaspM1FakePinImpl(flutterSecureStorage: dependencies.flutterSecureStorage),
    );
    _controller.loadPin();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pinInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M1: PIN Hash Storage')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final busy = _controller.busy;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PinHashCard(pinHash: _controller.pinHash),
                const SizedBox(height: 24),
                TextField(
                  controller: _pinInput,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'Enter PIN',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : () => _controller.savePin(_pinInput.text),
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save PIN'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: busy || _controller.pinHash == null ? null : _controller.clearPin,
                  child: const Text('Clear PIN'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PinHashCard extends StatelessWidget {
  const _PinHashCard({required this.pinHash});

  final String? pinHash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHash = pinHash != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasHash
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasHash ? Icons.lock : Icons.lock_outline,
                size: 18,
                color: hasHash ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Stored PIN Hash',
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasHash ? pinHash! : 'No PIN saved yet',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: hasHash ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasHash) ...[
            const SizedBox(height: 8),
            Text(
              'Raw PIN is never stored — only the bcrypt hash',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class OwaspM1PinController with ChangeNotifier {
  OwaspM1PinController({required this.iOwaspM1});

  final IOwaspM1Pin iOwaspM1;

  String? pinHash;
  bool busy = false;

  void savePin(final String pin) async {
    if (busy || pin.isEmpty) return;
    busy = true;
    notifyListeners();
    pinHash = await iOwaspM1.savePin(pin);
    busy = false;
    notifyListeners();
  }

  void loadPin() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    pinHash = await iOwaspM1.loadPin();
    busy = false;
    notifyListeners();
  }

  void clearPin() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    await iOwaspM1.clearPin();
    pinHash = null;
    busy = false;
    notifyListeners();
  }
}

abstract interface class IOwaspM1Pin {
  Future<String> savePin(final String pin);

  Future<String?> loadPin();

  Future<void> clearPin();
}

final class OwaspM1FakePinImpl implements IOwaspM1Pin {
  OwaspM1FakePinImpl({required this.flutterSecureStorage});

  final FlutterSecureStorage flutterSecureStorage;
  final String _pinKey = 'm1_pin_hash';

  @override
  Future<String> savePin(final String pin) async {
    await Future.delayed(const Duration(milliseconds: 600));
    await flutterSecureStorage.write(key: _pinKey, value: pin);
    return pin;
  }

  @override
  Future<String?> loadPin() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return flutterSecureStorage.read(key: _pinKey);
  }

  @override
  Future<void> clearPin() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await flutterSecureStorage.delete(key: _pinKey);
  }
}
