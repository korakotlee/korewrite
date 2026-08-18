## Why

`USAGE.md` and `README.md` are currently empty with no documentation on project capabilities, architecture, prerequisites, building from source, running tests, installing Quick Action services, or configuring custom prompt presets.
A polished GitHub-style `README.md` along with comprehensive developer and user instructions in `USAGE.md` are essential for seamless onboarding, local development, troubleshooting, and verification across macOS environments.

## What Changes

- Create a GitHub-style `README.md` showcasing project features, macOS Tahoe/Sonoma design alignment, architecture summary, quick start snippet, and repository navigation.
- Author a complete and structured `USAGE.md` guide covering prerequisites, build commands, test runs, and service installations.
- Document macOS Accessibility and Automation permission requirements for clipboard and keystroke simulation.
- Provide step-by-step instructions for building the release binary using `swift build -c release`.
- Provide commands for running automated unit and integration test suites using `swift test`.
- Detail the one-line installer command for installing and updating macOS Quick Actions into `~/Library/Services/`.
- Document how to create, manage, and customize user prompt files in `~/.korewrite/`.
- Include troubleshooting steps for Antigravity (`agy`) CLI path discovery, permission resets, and logging.

## Capabilities

### New Capabilities
- `build-and-usage-docs`: Developer and end-user operational documentation detailing build, test, service installation, custom preset management, project README, and troubleshooting.

### Modified Capabilities

## Impact

- Documentation: Replaces empty `README.md` and `USAGE.md` with polished GitHub documentation and developer manuals.
- Developer Experience: Standardizes build (`swift build`), test (`swift test`), and installation workflows across team members and contributors.
- Runtime Support: Lowers support overhead by providing actionable troubleshooting for Accessibility permissions and CLI tool detection.
