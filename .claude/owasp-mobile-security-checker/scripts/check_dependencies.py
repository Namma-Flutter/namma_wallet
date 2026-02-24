#!/usr/bin/env python3
"""
Check Flutter dependencies for security vulnerabilities (OWASP M2).

This script analyzes pubspec.yaml for outdated packages, version constraints,
and known vulnerabilities.
"""

import yaml
import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, List


def load_pubspec(project_root: str) -> Dict:
    """Load and parse pubspec.yaml."""
    pubspec_path = Path(project_root) / 'pubspec.yaml'

    if not pubspec_path.exists():
        print(f"Error: pubspec.yaml not found in {project_root}")
        sys.exit(1)

    with open(pubspec_path, 'r') as f:
        return yaml.safe_load(f)


def check_version_constraints(pubspec: Dict) -> List[Dict]:
    """Check for insecure version constraints."""
    findings = []

    dependencies = pubspec.get('dependencies', {})
    dev_dependencies = pubspec.get('dev_dependencies', {})

    all_deps = {**dependencies, **dev_dependencies}

    for package, version in all_deps.items():
        if package == 'flutter':
            continue

        # Check for 'any' version constraint (highly insecure)
        if version == 'any':
            findings.append({
                'package': package,
                'issue': 'Version constraint set to "any"',
                'severity': 'CRITICAL',
                'recommendation': 'Use specific version constraints (e.g., ^1.0.0)'
            })

        # Check for missing version constraint
        elif version is None:
            findings.append({
                'package': package,
                'issue': 'No version constraint specified',
                'severity': 'HIGH',
                'recommendation': 'Specify a version constraint'
            })

    return findings


def check_outdated_packages(project_root: str) -> Dict:
    """Run 'flutter pub outdated' to check for outdated packages."""
    try:
        result = subprocess.run(
            ['flutter', 'pub', 'outdated', '--json'],
            cwd=project_root,
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode == 0:
            return json.loads(result.stdout)
        else:
            print(f"Warning: flutter pub outdated failed: {result.stderr}")
            return {}
    except subprocess.TimeoutExpired:
        print("Warning: flutter pub outdated timed out")
        return {}
    except FileNotFoundError:
        print("Warning: flutter command not found. Skipping outdated check.")
        return {}
    except Exception as e:
        print(f"Warning: Error running flutter pub outdated: {e}")
        return {}


def analyze_outdated_results(outdated_data: Dict) -> List[Dict]:
    """Analyze outdated packages data."""
    findings = []

    packages = outdated_data.get('packages', [])

    for package in packages:
        current = package.get('current', {}).get('version')
        latest = package.get('latest', {}).get('version')
        resolvable = package.get('resolvable', {}).get('version')

        package_name = package.get('package')

        if current != latest:
            severity = 'MEDIUM'
            # Determine severity based on version gap
            if current and latest:
                current_major = int(current.split('.')[0]) if current.split('.')[0].isdigit() else 0
                latest_major = int(latest.split('.')[0]) if latest.split('.')[0].isdigit() else 0

                if latest_major > current_major:
                    severity = 'HIGH'

            findings.append({
                'package': package_name,
                'current_version': current,
                'latest_version': latest,
                'resolvable_version': resolvable,
                'severity': severity,
                'issue': 'Package is outdated',
                'recommendation': f'Update to version {latest}'
            })

    return findings


def check_dangerous_packages(pubspec: Dict) -> List[Dict]:
    """Check for known dangerous or deprecated packages."""
    findings = []

    # Known packages with security issues or deprecated
    dangerous_packages = {
        'http': {
            'versions': ['<0.13.0'],
            'issue': 'Old versions lack important security features',
            'severity': 'HIGH'
        },
        'path_provider': {
            'versions': ['<2.0.0'],
            'issue': 'Older versions have path traversal vulnerabilities',
            'severity': 'MEDIUM'
        },
    }

    dependencies = pubspec.get('dependencies', {})

    for package, version_info in dangerous_packages.items():
        if package in dependencies:
            findings.append({
                'package': package,
                'issue': version_info['issue'],
                'severity': version_info['severity'],
                'recommendation': 'Update to the latest stable version'
            })

    return findings


def main():
    """Main execution function."""
    project_root = sys.argv[1] if len(sys.argv) > 1 else '.'

    print(f"OWASP M2: Analyzing dependencies in {project_root}\n")

    # Load pubspec.yaml
    pubspec = load_pubspec(project_root)

    all_findings = []

    # Check version constraints
    print("Checking version constraints...")
    constraint_findings = check_version_constraints(pubspec)
    all_findings.extend(constraint_findings)

    # Check for outdated packages
    print("Checking for outdated packages...")
    outdated_data = check_outdated_packages(project_root)
    if outdated_data:
        outdated_findings = analyze_outdated_results(outdated_data)
        all_findings.extend(outdated_findings)

    # Check for dangerous packages
    print("Checking for known vulnerable packages...")
    dangerous_findings = check_dangerous_packages(pubspec)
    all_findings.extend(dangerous_findings)

    # Print results
    print(f"\n{'='*60}")
    print("Dependency Scan Results:")
    print(f"{'='*60}")
    print(f"Total issues found: {len(all_findings)}\n")

    if all_findings:
        # Group by severity
        by_severity = {'CRITICAL': [], 'HIGH': [], 'MEDIUM': [], 'LOW': []}
        for finding in all_findings:
            severity = finding.get('severity', 'MEDIUM')
            by_severity[severity].append(finding)

        for severity in ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']:
            if by_severity[severity]:
                print(f"\n{severity} Severity ({len(by_severity[severity])}):")
                print('-' * 60)
                for finding in by_severity[severity]:
                    print(f"\nPackage: {finding['package']}")
                    print(f"Issue: {finding['issue']}")
                    if 'current_version' in finding:
                        print(f"Current: {finding['current_version']}, Latest: {finding['latest_version']}")
                    print(f"Recommendation: {finding['recommendation']}")

    # Save results
    output_file = Path(project_root) / 'owasp_m2_dependencies_scan.json'
    with open(output_file, 'w') as f:
        json.dump({
            'total_issues': len(all_findings),
            'findings': all_findings
        }, f, indent=2)

    print(f"\n{'='*60}")
    print(f"Results saved to: {output_file}")

    # Exit with error if critical/high issues found
    critical_high = len(by_severity['CRITICAL']) + len(by_severity['HIGH'])
    sys.exit(1 if critical_high > 0 else 0)


if __name__ == '__main__':
    main()
