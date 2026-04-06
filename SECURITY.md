# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in the AppActor Flutter SDK, please report it responsibly.

**Please do NOT open a public GitHub issue for security vulnerabilities.**

Instead, email us at **security@appactor.com** with:

- A description of the vulnerability
- Steps to reproduce the issue
- The potential impact
- Any suggested fixes (optional)

We will acknowledge your report within **48 hours** and aim to provide a fix or mitigation within **7 business days**, depending on severity.

## Scope

This policy applies to the AppActor Flutter SDK source code in this repository.

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest  | Yes       |

## Security Practices

- All API communication uses HTTPS with TLS 1.2+
- The Dart layer delegates all network and storage operations to native SDKs
- No credentials or API keys are hardcoded in the SDK
- Debug logging is gated behind `kDebugMode`
