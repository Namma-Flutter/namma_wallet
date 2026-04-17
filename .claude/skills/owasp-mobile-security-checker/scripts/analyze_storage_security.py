#!/usr/bin/env python3
"""
Analyze data storage security in Flutter project (OWASP M9).

This script checks for insecure data storage patterns, including:
- Unencrypted SharedPreferences usage
- Plaintext file storage
- Insecure database implementations
"""

import re
import json
from pathlib import Path
from typing import List, Dict


def scan_shared_preferences_usage(file_path: Path) -> List[Dict]:
    """Scan for insecure SharedPreferences usage."""
    findings = []

    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.split('\n')

            # Check for SharedPreferences import
            has_shared_prefs = 'package:shared_preferences' in content
            has_secure_storage = 'package:flutter_secure_storage' in content

            if has_shared_prefs:
                # Look for sensitive data being stored
                sensitive_patterns = [
                    (r'setString\(["\'](?:token|auth|password|secret|key|credential)["\']', 'Token/Credential storage'),
                    (r'setString\(["\'].*(?:api|jwt|bearer).*["\']', 'API key storage'),
                    (r'setInt\(["\'](?:pin|otp|code)["\']', 'PIN/OTP storage'),
                ]

                for line_num, line in enumerate(lines, 1):
                    for pattern, issue_type in sensitive_patterns:
                        if re.search(pattern, line, re.IGNORECASE):
                            findings.append({
                                'file': str(file_path),
                                'line': line_num,
                                'issue': f'{issue_type} in unencrypted SharedPreferences',
                                'code': line.strip(),
                                'severity': 'HIGH',
                                'recommendation': 'Use flutter_secure_storage instead'
                            })

    except Exception as e:
        print(f"Error scanning {file_path}: {e}")

    return findings


def scan_file_storage(file_path: Path) -> List[Dict]:
    """Scan for insecure file storage patterns."""
    findings = []

    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.split('\n')

            # Patterns for insecure file operations
            insecure_patterns = [
                (r'File\(.*\)\.writeAsString\((?!.*encrypt)', 'Unencrypted file write'),
                (r'File\(.*\)\.writeAsBytes\((?!.*encrypt)', 'Unencrypted file write'),
                (r'openWrite\(', 'Potentially unencrypted stream write'),
            ]

            for line_num, line in enumerate(lines, 1):
                for pattern, issue_type in insecure_patterns:
                    if re.search(pattern, line):
                        # Check if encryption is mentioned nearby
                        context_start = max(0, line_num - 3)
                        context_end = min(len(lines), line_num + 3)
                        context = '\n'.join(lines[context_start:context_end])

                        if 'encrypt' not in context.lower():
                            findings.append({
                                'file': str(file_path),
                                'line': line_num,
                                'issue': issue_type,
                                'code': line.strip(),
                                'severity': 'MEDIUM',
                                'recommendation': 'Encrypt sensitive data before writing to files'
                            })

    except Exception as e:
        print(f"Error scanning {file_path}: {e}")

    return findings


def scan_database_security(file_path: Path) -> List[Dict]:
    """Scan for insecure database implementations."""
    findings = []

    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.split('\n')

            # Check for sqflite without encryption
            has_sqflite = 'package:sqflite' in content
            has_encrypted_sqflite = 'sqflite_sqlcipher' in content

            if has_sqflite and not has_encrypted_sqflite:
                findings.append({
                    'file': str(file_path),
                    'line': 1,
                    'issue': 'Unencrypted SQLite database',
                    'code': 'import package:sqflite',
                    'severity': 'HIGH',
                    'recommendation': 'Consider using sqflite_sqlcipher for encrypted databases'
                })

            # Check for raw SQL queries (injection risk)
            for line_num, line in enumerate(lines, 1):
                if re.search(r'rawQuery\(["\']SELECT.*\$', line):
                    findings.append({
                        'file': str(file_path),
                        'line': line_num,
                        'issue': 'Potential SQL injection via string interpolation',
                        'code': line.strip(),
                        'severity': 'HIGH',
                        'recommendation': 'Use parameterized queries with whereArgs'
                    })

    except Exception as e:
        print(f"Error scanning {file_path}: {e}")

    return findings


def scan_backup_configuration(project_root: Path) -> List[Dict]:
    """Check Android backup configuration."""
    findings = []

    android_manifest = project_root / 'android' / 'app' / 'src' / 'main' / 'AndroidManifest.xml'

    if android_manifest.exists():
        try:
            with open(android_manifest, 'r') as f:
                content = f.read()

                # Check if backup is disabled or restricted
                if 'android:allowBackup="false"' not in content and 'android:fullBackupContent' not in content:
                    findings.append({
                        'file': str(android_manifest),
                        'line': 0,
                        'issue': 'Backup not explicitly configured',
                        'code': '<application>',
                        'severity': 'MEDIUM',
                        'recommendation': 'Set android:allowBackup="false" or configure android:fullBackupContent'
                    })

                if 'android:allowBackup="true"' in content:
                    findings.append({
                        'file': str(android_manifest),
                        'line': 0,
                        'issue': 'Full backup enabled - sensitive data may be backed up',
                        'code': 'android:allowBackup="true"',
                        'severity': 'HIGH',
                        'recommendation': 'Disable backup or use selective backup rules'
                    })

        except Exception as e:
            print(f"Error scanning {android_manifest}: {e}")

    return findings


def scan_project(project_root: str) -> Dict:
    """Scan entire Flutter project for storage security issues."""
    project_path = Path(project_root)
    all_findings = []

    # Get all Dart files
    dart_files = list(project_path.glob('lib/**/*.dart'))

    print(f"Scanning {len(dart_files)} Dart files for storage security issues...")

    for file_path in dart_files:
        findings = []
        findings.extend(scan_shared_preferences_usage(file_path))
        findings.extend(scan_file_storage(file_path))
        findings.extend(scan_database_security(file_path))
        all_findings.extend(findings)

    # Check Android backup configuration
    backup_findings = scan_backup_configuration(project_path)
    all_findings.extend(backup_findings)

    return {
        'total_files_scanned': len(dart_files),
        'total_findings': len(all_findings),
        'findings': all_findings
    }


def main():
    """Main execution function."""
    import sys

    project_root = sys.argv[1] if len(sys.argv) > 1 else '.'

    print(f"OWASP M9: Analyzing data storage security in {project_root}\n")

    results = scan_project(project_root)

    print(f"\n{'='*60}")
    print("Storage Security Scan Results:")
    print(f"{'='*60}")
    print(f"Files scanned: {results['total_files_scanned']}")
    print(f"Issues found: {results['total_findings']}\n")

    if results['findings']:
        # Group by severity
        by_severity = {'CRITICAL': [], 'HIGH': [], 'MEDIUM': [], 'LOW': []}
        for finding in results['findings']:
            severity = finding.get('severity', 'MEDIUM')
            by_severity[severity].append(finding)

        for severity in ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']:
            if by_severity[severity]:
                print(f"\n{severity} Severity ({len(by_severity[severity])}):")
                print('-' * 60)
                for i, finding in enumerate(by_severity[severity], 1):
                    print(f"\n{i}. {finding['issue']}")
                    print(f"   File: {finding['file']}:{finding['line']}")
                    if finding.get('code'):
                        print(f"   Code: {finding['code']}")
                    print(f"   Recommendation: {finding['recommendation']}")

    # Save results
    output_file = Path(project_root) / 'owasp_m9_storage_scan.json'
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)

    print(f"\n{'='*60}")
    print(f"Results saved to: {output_file}")

    # Exit with error if high/critical issues found
    sys.exit(1 if results['total_findings'] > 0 else 0)


if __name__ == '__main__':
    main()
