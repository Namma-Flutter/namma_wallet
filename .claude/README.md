# Flutter Claude Skills 

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A collection of specialized Claude Code skills for Flutter development, focusing on testing and security best practices.

<img width="720" height="480" alt="Gemini_Generated_Image_hc8b78hc8b78hc8b" src="https://github.com/user-attachments/assets/57cdb77d-db53-4e94-a429-5f4b6a3b4166" />

## What are Claude Skills?

[Claude Code](https://code.claude.com/) is Anthropic's official CLI tool that brings Claude AI directly to your terminal. Skills are modular capabilities that extend Claude's functionality for specific domains or tasks. Each skill consists of a `SKILL.md` file with instructions, plus optional supporting files like scripts and templates.

**Skills are model-invoked** - Claude autonomously decides when to activate them based on your request and the skill's description. You don't need to explicitly call a skill; simply describe what you want to do, and Claude will activate the relevant skill automatically.

## Available Skills

### 1. Flutter Tester

**Name:** `flutter-tester`

**Purpose:** Comprehensive testing guidance for Flutter applications

A specialized skill that provides expert guidance on creating, writing, and analyzing tests in Flutter projects. Covers the full spectrum of testing including unit tests, widget tests, integration tests, and provides deep knowledge of mocking patterns, Riverpod state management testing, and industry best practices.

**Key Features:**

- Given-When-Then test structure patterns
- Layer-by-layer testing strategies (Data, Domain, Presentation, Application)
- Mockito and Riverpod testing patterns
- Widget testing with proper screen size setup and key usage
- Database testing with FakeDatabase
- Stream, timer, and async testing patterns
- Comprehensive test checklists and verification patterns

**Reference Documentation:**

- Layer testing patterns (repositories, providers, DAOs)
- Widget testing guide with interaction patterns
- Riverpod testing guide for state management

---

### 2. OWASP Mobile Security Checker

**Name:** `owasp-mobile-security-checker`

**Purpose:** Security analysis and vulnerability assessment for Flutter mobile applications

A comprehensive security auditing skill based on the OWASP Mobile Top 10 (2024) guidelines. Combines automated Python scanning scripts with detailed manual analysis workflows to identify vulnerabilities, assess security posture, and provide actionable remediation guidance.

**Key Features:**

- **Automated Scanners:**
  - M1: Hardcoded secrets and credential detection
  - M2: Dependency security and outdated package analysis
  - M5: Network security validation (HTTPS, certificate pinning)
  - M9: Storage security analysis (encryption, secure storage)

- **Manual Analysis Guidance:**
  - M3: Authentication and authorization patterns
  - M4: Input/output validation strategies
  - M6: Privacy controls and PII handling
  - M7: Binary protections and obfuscation
  - M8: Security misconfiguration detection
  - M10: Cryptography implementation review

- **Comprehensive Reporting:**
  - Severity-based prioritization (CRITICAL → HIGH → MEDIUM → LOW)
  - Flutter-specific code examples
  - Actionable remediation steps
  - OWASP risk categorization

**Reference Documentation:**

- OWASP Mobile Top 10 (2024) detailed guide
- Flutter-specific vulnerability patterns
- Secure vs insecure code examples

---

## Installation

### Prerequisites

- [Claude Code](https://code.claude.com/) installed and configured
- For OWASP Security Checker: Python 3.7+

### Setup Options

Skills can be installed in two locations:

#### Option 1: Personal Skills (Recommended for individual use)

Install to `~/.claude/skills/` for use across all your projects:

```bash
cd ~/.claude/skills/
git clone https://github.com/Harishwarrior/flutter-claude-skills.git
```

After cloning, the skills will be available in:

- `~/.claude/skills/flutter-claude-skills/flutter-tester/`
- `~/.claude/skills/flutter-claude-skills/owasp-mobile-security-checker/`

#### Option 2: Project Skills (Recommended for team use)

Install to `.claude/skills/` in your Flutter project for team sharing:

```bash
cd /path/to/your/flutter/project
mkdir -p .claude/skills
cd .claude/skills
git clone https://github.com/Harishwarrior/flutter-claude-skills.git
```

Commit the `.claude/skills/` directory to git so team members automatically get the skills when they pull.

**Note:** Claude automatically discovers skills from both locations. No additional configuration needed.

---

## Usage

Skills are **automatically activated** by Claude based on your request. You don't need to explicitly invoke them - just describe what you want to do naturally.

### Flutter Tester - Example Requests

Claude will automatically activate the `flutter-tester` skill when you work on Flutter tests:

```bash
# In your Flutter project directory
claude
```

**Example conversations:**

```text
"Help me write widget tests for my LoginScreen"
→ Claude detects you need testing help and activates flutter-tester

"Create unit tests for my UserRepository class"
→ Automatically uses flutter-tester patterns

"My widget tests in auth_screen_test.dart are failing. Can you help debug them?"
→ Claude applies flutter-tester debugging guidelines

"How should I test Riverpod providers?"
→ Provides Riverpod testing patterns from the skill

"Review my test coverage and suggest missing test cases"
→ Uses flutter-tester checklist and best practices
```

### OWASP Mobile Security Checker - Example Requests

Claude will automatically activate the `owasp-mobile-security-checker` skill for security-related requests:

**For automated scanning:**

```text
"Check my Flutter app for hardcoded secrets and API keys"
→ Claude runs scan_hardcoded_secrets.py

"Scan my dependencies for security vulnerabilities"
→ Claude runs check_dependencies.py

"Verify my app uses HTTPS and has proper certificate pinning"
→ Claude runs check_network_security.py

"Analyze my app's data storage for security issues"
→ Claude runs analyze_storage_security.py

"Perform a comprehensive OWASP security audit"
→ Claude runs all scanners and performs manual analysis
```

**For manual analysis:**

```text
"Review my authentication implementation for security issues"
→ Claude applies M3 (Authentication) guidelines

"Check my app for input validation vulnerabilities"
→ Claude applies M4 (Input Validation) patterns

"Audit my cryptography implementation"
→ Claude applies M10 (Cryptography) best practices
```

### Running Scanners Manually

You can also run the security scanners directly:

```bash
# From your Flutter project root
cd /path/to/your/flutter/project

# Run individual scanners
python3 ~/.claude/skills/flutter-claude-skills/owasp-mobile-security-checker/scripts/scan_hardcoded_secrets.py .
python3 ~/.claude/skills/flutter-claude-skills/owasp-mobile-security-checker/scripts/check_dependencies.py .
python3 ~/.claude/skills/flutter-claude-skills/owasp-mobile-security-checker/scripts/check_network_security.py .
python3 ~/.claude/skills/flutter-claude-skills/owasp-mobile-security-checker/scripts/analyze_storage_security.py .
```

Results are saved as JSON files in your project directory.

---

## Skill Details

### Flutter Tester Structure

```text
flutter-tester/
├── SKILL.md                          # Main skill definition and guidance
└── references/
    ├── layer_testing_patterns.md     # Repository, Provider, DAO testing patterns
    ├── widget_testing_guide.md       # Widget interaction and UI testing
    └── riverpod_testing_guide.md     # State management testing with Riverpod
```

### OWASP Mobile Security Checker Structure

```text
owasp-mobile-security-checker/
├── SKILL.md                                    # Main skill definition and workflows
├── scripts/
│   ├── scan_hardcoded_secrets.py              # M1: Credential scanning
│   ├── check_dependencies.py                  # M2: Package security
│   ├── check_network_security.py              # M5: Network config validation
│   └── analyze_storage_security.py            # M9: Storage security analysis
└── references/
    └── owasp_mobile_top_10_2024.md            # Complete OWASP guide with examples
```

---

## Contributing

Contributions are welcome! Here's how you can help:

1. **Report issues** - Found a bug or have a suggestion? Open an issue
2. **Improve patterns** - Have a better testing or security pattern? Submit a PR
3. **Add examples** - More real-world examples are always helpful
4. **Update scanners** - Help keep the security scanners current with new patterns
5. **Documentation** - Improve guides, add clarifications, fix typos

### Contribution Guidelines

- Follow the existing structure and formatting
- Test your changes thoroughly
- Update relevant documentation
- Add examples where appropriate
- Keep security scanner patterns up-to-date with latest threats

---

## Resources

### Flutter Testing

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)
- [flutter_test Package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

### Mobile Security

- [OWASP Mobile Top 10 (2024)](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Android Security Guidelines](https://developer.android.com/topic/security/best-practices)
- [iOS Security Guide](https://support.apple.com/guide/security/welcome/web)

### Claude Code

- [Claude Code Documentation](https://code.claude.com/docs)
- [Creating Custom Skills](https://code.claude.com/docs/en/skills)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/Harishwarrior/flutter-claude-skills/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Harishwarrior/flutter-claude-skills/discussions)

---

## Acknowledgments

- Built for [Claude Code](https://code.claude.com/) by Anthropic
- Testing patterns based on Flutter community best practices
- Security guidelines based on [OWASP Mobile Top 10 (2024)](https://owasp.org/www-project-mobile-top-10/)
- Inspired by the Flutter and mobile security communities
