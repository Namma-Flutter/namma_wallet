# OWASP Mobile Top 10 (2024) - Comprehensive Reference

This document provides detailed information about the OWASP Mobile Top 10 risks for 2024, including real-world scenarios, attack flows, and mitigation strategies specifically for Flutter/Dart applications.

---

## M1: Improper Credential Usage

### M1 - What it Means

Storing secrets like API keys, tokens, and credentials inside mobile binaries makes them accessible to attackers who can decompile the application.

### M1 - Real-World Examples

- **Fintech app** exposed AWS keys in APK → backend takeover
- **Firebase keys** in a ride-sharing app → attackers mass downloaded user data
- **Chat app** stored credentials in SharedPreferences, retrievable via root

### M1 - Attacker Flow

1. Decompile APK/IPA
2. Extract credentials from code or resources
3. Abuse API or gain unauthorized access

### M1 - Flutter-Specific Vulnerabilities

- Hardcoded API keys in Dart code
- Secrets in `pubspec.yaml` or environment files
- Firebase config hardcoded in `google-services.json` or `GoogleService-Info.plist`
- Tokens stored in unencrypted SharedPreferences
- API keys in `android/app/build.gradle` or iOS `Info.plist`

### M1 - Mitigation Strategies

- **Use secure storage**: `flutter_secure_storage` for Android Keystore/iOS Keychain
- **Backend token generation**: Never store long-lived credentials; fetch tokens at runtime
- **Environment variables**: Use build-time injection, not hardcoded values
- **API key rotation**: Implement regular rotation and minimum privileges
- **Obfuscation**: Use code obfuscation (though not a primary defense)

### M1 - Flutter Code Patterns to Check

```dart
// ❌ BAD: Hardcoded credentials
const String apiKey = "sk_live_ABC123...";
const String apiSecret = "secret_key_xyz";

// ✅ GOOD: Runtime fetching with secure storage
final secureStorage = FlutterSecureStorage();
String? apiKey = await secureStorage.read(key: 'api_key');
```

---

## M2: Inadequate Supply Chain Security

### M2 - What it Means

Third-party packages, SDKs, and dependencies may be outdated, vulnerable, or maliciously tampered with.

### M2 - Real-World Examples

- **XcodeGhost**: Spread via infected Xcode version, compromising thousands of iOS apps
- **Analytics SDKs** in game apps leaked sensitive device data
- **Apache Struts vulnerability** similar to Equifax breach

### M2 - Attacker Flow

1. Compromise a third-party library or package
2. Inject malicious code
3. Apps using the compromised dependency inherit the risk

### M2 - Flutter-Specific Vulnerabilities

- Outdated packages in `pubspec.yaml`
- Unverified pub.dev packages
- Native plugins with security vulnerabilities
- Dependencies with transitive vulnerabilities
- Malicious packages with typosquatting names

### M2 - Mitigation Strategies

- **Dependency scanning**: Use `dart pub outdated` and SCA tools
- **Package verification**: Check pub.dev scores, popularity, and maintenance
- **Lock dependencies**: Use `pubspec.lock` to ensure consistent versions
- **Regular updates**: Monitor security advisories for Flutter and packages
- **Minimal dependencies**: Only include necessary packages

### M2 - Flutter Code Patterns to Check

```yaml
# ❌ BAD: No version constraints
dependencies:
  http: any

# ✅ GOOD: Specific version constraints
dependencies:
  http: ^1.1.0
```

---

## M3: Insecure Authentication/Authorization

### M3 - What it Means

Flawed login/session handling, weak password policies, or insufficient server-side access controls.

### M3 - Real-World Examples

- **Banking app** bypassed 2FA via query manipulation
- **E-commerce sessions** never expired → session hijacking
- **Starbucks mobile app** stored plaintext credentials

### M3 - Attacker Flow

1. Brute force weak credentials
2. Hijack or reuse session tokens
3. Bypass authentication controls

### M3 - Flutter-Specific Vulnerabilities

- Session tokens stored in plain SharedPreferences
- No token expiration or refresh mechanism
- Client-side authentication checks only
- Weak or no biometric authentication
- Missing certificate pinning allows MITM attacks

### M3 - Mitigation Strategies

- **Multi-Factor Authentication (MFA)**: Implement OTP, biometrics
- **Secure token storage**: Use `flutter_secure_storage`
- **Token lifecycle**: Implement expiration, refresh, and revocation
- **RBAC**: Server-side role-based access control
- **Biometric authentication**: Use `local_auth` package properly

### M3 - Flutter Code Patterns to Check

```dart
// ❌ BAD: Plaintext token storage
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);

// ✅ GOOD: Secure token storage
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
```

---

## M4: Insufficient Input/Output Validation

### M4 - What it Means

Lack of validation and sanitization for user input or backend responses, leading to injection attacks and data exposure.

### M4 - Real-World Examples

- **Settings app** processed malicious file types
- **Chat app** rendered HTML/JS in usernames → XSS
- **API accepted** `?id=123` exposing unauthorized user data (IDOR)

### M4 - Attacker Flow

1. Inject malicious input (SQL, XSS, path traversal)
2. Server processes without validation
3. Exploit or leak sensitive data

### M4 - Flutter-Specific Vulnerabilities

- Unvalidated user input in forms
- Direct use of user input in file paths or URLs
- Missing sanitization in WebView content
- No validation of server responses
- SQL injection in local SQLite databases

### M4 - Mitigation Strategies

- **Input validation**: Whitelist allowed characters and formats
- **Output encoding**: Sanitize data before display, especially in WebViews
- **Parameterized queries**: Use prepared statements for database operations
- **JSON schema validation**: Validate API responses
- **Rate limiting**: Prevent abuse through excessive requests

### M4 - Flutter Code Patterns to Check

```dart
// ❌ BAD: No input validation
String query = "SELECT * FROM users WHERE id = ${userInput}";

// ✅ GOOD: Parameterized query
await db.query('users', where: 'id = ?', whereArgs: [userId]);
```

---

## M5: Insecure Communication

### M5 - What it Means

Lack of encryption or secure protocols (HTTPS, TLS) for transmitting sensitive data.

### M5 - Real-World Examples

- **Kids smartwatches** sent GPS via unencrypted SMS
- **Weather app** used HTTP, exposing users on public Wi-Fi
- **Fitness app** leaked payment data via insecure transport

### M5 - Attacker Flow

1. Intercept network traffic (MITM attack)
2. Steal tokens, PII, passwords
3. Replay or modify requests

### M5 - Flutter-Specific Vulnerabilities

- HTTP instead of HTTPS in API calls
- Missing certificate pinning
- Accepting all SSL certificates (during development, left in production)
- Sensitive data in URL parameters
- WebSocket connections without TLS

### M5 - Mitigation Strategies

- **Enforce TLS 1.2+**: Use HTTPS for all network communication
- **Certificate pinning**: Implement with `http_certificate_pinning` or custom `HttpClient`
- **Secure WebSockets**: Use WSS instead of WS
- **Avoid sensitive data in URLs**: Use POST body instead of query parameters
- **Network security config**: Configure properly for Android

### M5 - Flutter Code Patterns to Check

```dart
// ❌ BAD: HTTP connection
final response = await http.get(Uri.parse('http://api.example.com/data'));

// ✅ GOOD: HTTPS with certificate pinning
final client = HttpClient()..badCertificateCallback = (cert, host, port) => false;
```

---

## M6: Inadequate Privacy Controls

### M6 - What it Means

Apps mishandle Personally Identifiable Information (PII) or share data without proper consent.

### M6 - Real-World Examples

- **Family tracking app** leaked live location due to poor PIN protection
- **Health app** sent sensitive data to third-party analytics
- **Crash logs** included user emails and addresses

### M6 - Attacker Flow

1. Access logs, analytics, or backups
2. Extract PII
3. Track or identify users

### M6 - Flutter-Specific Vulnerabilities

- Excessive permissions requested
- PII in analytics events
- Sensitive data in crash reports
- Unencrypted local storage of PII
- Missing privacy policy or consent mechanisms

### M6 - Mitigation Strategies

- **Explicit permissions**: Request only necessary permissions with clear explanations
- **Data minimization**: Collect only essential data
- **Anonymization**: Remove or hash PII in logs and analytics
- **Secure backups**: Encrypt or exclude sensitive data from backups
- **Privacy policy**: Implement clear consent mechanisms

### M6 - Flutter Code Patterns to Check

```dart
// ❌ BAD: Excessive permissions, logging PII
print('User email: ${user.email}');
FirebaseAnalytics.logEvent(name: 'login', parameters: {'email': user.email});

// ✅ GOOD: Minimal logging, anonymized analytics
logger.info('User logged in');
FirebaseAnalytics.logEvent(name: 'login', parameters: {'user_id': hashedId});
```

---

## M7: Insufficient Binary Protections

### M7 - What it Means

Lack of protections against reverse engineering, tampering, and intellectual property theft.

### M7 - Real-World Examples

- **Games** had in-app purchase checks patched out
- **Bank app's** encryption key extracted via reverse engineering
- **AI models** stolen and reused from APKs

### M7 - Attacker Flow

1. Decompile app binary
2. Analyze or modify app logic
3. Repackage and re-sign

### M7 - Flutter-Specific Vulnerabilities

- No code obfuscation enabled
- Missing root/jailbreak detection
- No runtime integrity checks
- Debug mode left enabled in production
- Easily extractable assets and resources

### M7 - Mitigation Strategies

- **Code obfuscation**: Enable `--obfuscate` flag in release builds
- **Root detection**: Use `flutter_jailbreak_detection` or similar
- **Anti-debugging**: Detect debugger attachment at runtime
- **Integrity checks**: Verify app signature and checksum
- **ProGuard/R8**: Configure for Android native code

### M7 - Flutter Build Commands

```bash
# ❌ BAD: No obfuscation
flutter build apk --release

# ✅ GOOD: With obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

## M8: Security Misconfiguration

### M8 - What it Means

Misconfigured environments, excessive permissions, forgotten debug features, or insecure default settings.

### M8 - Real-World Examples

- **Production app** still had debug logging enabled
- **Admin routes** like `/debug` were not secured
- **App requested** unnecessary permissions (e.g., storage, camera)

### M8 - Attacker Flow

1. Find exposed logs, debug endpoints, or misconfigurations
2. Exploit to gain access or information
3. Escalate privileges or access

### M8 - Flutter-Specific Vulnerabilities

- Debug mode enabled in production
- Verbose logging in release builds
- Default security settings not hardened
- Unnecessary platform permissions
- Development certificates in production

### M8 - Mitigation Strategies

- **Disable debugging**: Ensure debug flags are off in production
- **Minimal logging**: Remove or reduce logging in release builds
- **Least privilege**: Request only necessary permissions
- **Automated config scans**: Use CI/CD checks
- **Secure defaults**: Follow platform-specific security guidelines

### M8 - Flutter Code Patterns to Check

```dart
// ❌ BAD: Debug code in production
if (kDebugMode) {
  print('Debug info: ${sensitiveData}');
} // This still compiles in release

// ✅ GOOD: Removed in release builds
assert(() {
  print('Debug info');
  return true;
}());
```

---

## M9: Insecure Data Storage

### M9 - What it Means

Storing sensitive data (tokens, PII, credentials) in insecure local storage or backups.

### M9 - Real-World Examples

- **Chat logs** saved in unencrypted SharedPreferences
- **App backups** included user data retrievable by attackers
- **Fitness stats** stored in world-readable files

### M9 - Attacker Flow

1. Access device storage (via malware, physical access, or backup)
2. Extract sensitive data from insecure storage
3. Abuse credentials or PII

### M9 - Flutter-Specific Vulnerabilities

- Sensitive data in SharedPreferences (unencrypted)
- Files stored in world-readable directories
- Data included in device backups
- SQLite databases without encryption
- Cached data not cleared on logout

### M9 - Mitigation Strategies

- **Encrypted storage**: Use `flutter_secure_storage` or `encrypted_shared_preferences`
- **Database encryption**: Use `sqflite_sqlcipher` for encrypted SQLite
- **Backup exclusion**: Configure Android `android:allowBackup="false"` or selective backup
- **Clear on logout**: Delete all user data when user logs out
- **Temporary files**: Securely delete temporary files

### M9 - Flutter Code Patterns to Check

```dart
// ❌ BAD: Unencrypted storage
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('credit_card', cardNumber);

// ✅ GOOD: Encrypted storage
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'credit_card', value: cardNumber);
```

---

## M10: Insufficient Cryptography

### M10 - What it Means

Use of weak encryption algorithms, poor key management, insecure modes, or custom/broken crypto implementations.

### M10 - Real-World Examples

- **AES in ECB mode** exposed ciphertext patterns
- **Reused IVs** allowed predictable encryption
- **Custom cipher** cracked by researchers in under 12 hours

### M10 - Attacker Flow

1. Identify weak crypto implementation
2. Analyze or brute-force keys
3. Decrypt sensitive content

### M10 - Flutter-Specific Vulnerabilities

- Weak encryption algorithms (DES, MD5, SHA1)
- Hardcoded encryption keys
- ECB mode instead of CBC/GCM
- Poor random number generation
- Custom crypto implementations

### M10 - Mitigation Strategies

- **Strong algorithms**: Use AES-256 GCM, ChaCha20-Poly1305
- **Secure key management**: Store keys in Keystore/Keychain, not in code
- **Proper modes**: Use authenticated encryption (GCM, not ECB)
- **Cryptographically secure RNG**: Use `dart:math.Random.secure()`
- **Established libraries**: Use `pointycastle` or `cryptography` packages

### M10 - Flutter Code Patterns to Check

```dart
// ❌ BAD: Weak crypto, hardcoded key
import 'package:crypto/crypto.dart';
final key = 'hardcoded_key_123';
final encrypted = md5.convert(utf8.encode(data));

// ✅ GOOD: Strong crypto with secure key storage
import 'package:encrypt/encrypt.dart';
final key = await secureStorage.read(key: 'encryption_key');
final encrypter = Encrypter(AES(Key.fromBase64(key!), mode: AESMode.gcm));
```

---

## Quick Reference Summary

| Risk | Issue | Common Attack | Flutter-Specific Checks |
|------|-------|---------------|------------------------|
| **M1** | Hardcoded credentials | Key extraction | Check for hardcoded API keys, secrets in code/config files |
| **M2** | Vulnerable dependencies | Supply-chain injection | Review `pubspec.yaml`, check for outdated packages |
| **M3** | Weak authentication | Bypass/brute force | Verify secure token storage, MFA implementation |
| **M4** | Input validation | Injection/IDOR | Check input validation, parameterized queries |
| **M5** | Insecure communication | MITM sniffing | Ensure HTTPS, certificate pinning |
| **M6** | PII leakage | Log/analytics leaks | Review permissions, logging, analytics events |
| **M7** | No obfuscation | Reverse engineering | Verify obfuscation in builds, root detection |
| **M8** | Misconfiguration | Debug/endpoint abuse | Check debug flags, logging levels, permissions |
| **M9** | Plaintext storage | Backup/storage theft | Verify encrypted storage usage |
| **M10** | Weak cryptography | Decryption | Review crypto algorithms, key management |

---

## Additional Resources

- [OWASP Mobile Top 10 Project](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [iOS Security Guide](https://support.apple.com/guide/security/welcome/web)
- [XcodeGhost Incident](https://en.wikipedia.org/wiki/XcodeGhost)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Android Keystore System](https://developer.android.com/training/articles/keystore)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
