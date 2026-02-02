# Contributing to COP310 Compliance Automation

Thank you for your interest in contributing! This project is a portfolio demonstration of AWS compliance automation, but contributions are welcome.

## How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/your-improvement`)
3. **Make your changes** and test thoroughly
4. **Commit with clear messages** (see commit conventions below)
5. **Push to your fork** (`git push origin feature/your-improvement`)
6. **Open a Pull Request** with a clear description

## Commit Message Convention

```
[LabX] Brief description (50 chars or less)

- Detailed change 1
- Detailed change 2

Fixes: #issue-number (if applicable)
```

Examples:
- `[Lab1] Add support for eu-west-1 region`
- `[Lab2] Fix SSM document JSON syntax error`
- `[Docs] Update cost estimates for 2026 pricing`

## Code Style

- **Terraform:** Run `terraform fmt -recursive` before committing
- **Documentation:** Use markdownlint for README consistency
- **Comments:** Explain *why*, not *what* (code explains what)

## Testing Checklist

Before submitting a PR:
- [ ] `terraform fmt -check -recursive` passes
- [ ] `terraform validate` passes in all lab directories
- [ ] Cost estimates updated if resources changed
- [ ] README.md updated with new steps/screenshots
- [ ] No hardcoded account IDs, regions, or secrets

## Areas for Contribution

- **Additional regions:** Extend labs to support multi-region deployments
- **Custom Config rules:** Add Lambda-based custom compliance checks
- **SSM documents:** More remediation runbooks (e.g., unused IAM roles)
- **Diagrams:** Architecture diagrams using PlantUML or Mermaid
- **CI/CD:** GitHub Actions workflows for automated validation
- **Security Hub integration:** Aggregate Config findings with Security Hub

## Questions?

Open an issue or reach out via the contact info in the main README.

Happy automating! 🚀
