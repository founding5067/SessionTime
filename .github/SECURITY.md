# Security Policy

## Reporting a Vulnerability

### Responsible Disclosure

We appreciate responsible vulnerability reporting from the security community. If you have found a security vulnerability, please:

1. **Disclose privately** via email: `security@founding5067.dev`
2. **Include details**:
   - Vulnerability description
   - Steps to reproduce
   - Impact/affected versions
   - Suggested fix (optional)

### Timeline

We commit to the following timeline for addressing reported vulnerabilities:

- **Confirmation**: Within 48 hours, we'll confirm receipt and validate the issue
- **Assessment**: Within 7 days, we'll provide our assessment of the risk
- **Resolution**: Critical issues will be addressed within 14 days
- **Disclosure**: Full disclosure will be made after a fix is deployed

### What We Don't Accept

Please do **NOT** publicly disclose vulnerabilities in:
- GitHub Issues
- Public forums or forums
- Social media
- Public vulnerability databases

### Security Best Practices

If you're contributing to this repository:

```
# DO's
- Test your changes thoroughly
- Run all tests before pushing
- Follow secure coding practices
- Don't commit secrets or credentials

# Don't's
- Never commit API keys or passwords
- Don't commit .env files
- Don't commit certificate files
- Don't commit private keys
- Don't commit database credentials
```

### Sensitive Data

The following should NEVER be committed to this repository:

- API keys
- Passwords
- Tokens
- Private keys
- Database credentials
- Certificate files
- Personal identifiable information (PII)
- Source code for third-party dependencies (except proper imports)

## Code Quality Standards

To ensure code quality and security:

- ✅ All code must pass CI checks
- ✅ Tests must be included for new features
- ✅ Code must be properly formatted
- ✅ No force pushes to `main` branch
- ✅ PRs must be reviewed and approved by maintainers

## Security Updates

Security updates will be released promptly when vulnerabilities are discovered and fixes are implemented.

---

**Note:** This repository is public for educational purposes. Please practice responsible security and report vulnerabilities privately.

---

**Maintained by:** founding5067