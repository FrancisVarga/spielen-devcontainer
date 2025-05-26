# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0](https://github.com/FrancisVarga/spielen-devcontainer/compare/developer-environment-v0.1.0...developer-environment-v0.2.0) (2025-05-26)


### Features

* Add comprehensive SSH key setup for all codespaces ([7538811](https://github.com/FrancisVarga/spielen-devcontainer/commit/7538811ee84768a15f07cda93cbdc05e44e3a6b6))
* Enhance release-please workflow permissions and token handling ([2e42b5e](https://github.com/FrancisVarga/spielen-devcontainer/commit/2e42b5ee4e1abdc39804a48c4d629cae8037d981))
* Fix CI/CD pipeline container startup and testing issues ([e35794c](https://github.com/FrancisVarga/spielen-devcontainer/commit/e35794c0807d02441b85c33fe5a803252dc2c59a))
* Fix container exit issue and add documentation ([b905c5f](https://github.com/FrancisVarga/spielen-devcontainer/commit/b905c5f0faf36cb4b36515401587300be04a78e6))
* Initial project setup with Docker development environment ([0c2d731](https://github.com/FrancisVarga/spielen-devcontainer/commit/0c2d7319530b677f103b64edcfdd6e3b52917a94))
* Remove development documentation and devcontainer config ([bfacc6f](https://github.com/FrancisVarga/spielen-devcontainer/commit/bfacc6feebc50f457ddb8d75dd7718b58738dbe1))
* Update release-please action to use googleapis org ([f93964d](https://github.com/FrancisVarga/spielen-devcontainer/commit/f93964da04fbada675c894827ce5094a3116f066))


### Bug Fixes

* Pin release-please-action to v4 ([13b3242](https://github.com/FrancisVarga/spielen-devcontainer/commit/13b3242fb586f27d900fb54677318a3e281217a5))
* Remove macOS-specific UseKeychain option from SSH config ([74289d0](https://github.com/FrancisVarga/spielen-devcontainer/commit/74289d03614d18ffa79f26b43d7787965c999060))
* resolve GitHub Actions workflow issues ([701f929](https://github.com/FrancisVarga/spielen-devcontainer/commit/701f929b4bf2ff10ce927216f364a66bf043863b))

## [Unreleased]

### Features
- Initial developer environment Docker container
- Pre-installed Python versions (3.11.7, 3.12.1) via pyenv
- Pre-installed Node.js (LTS and latest) via nvm
- Go 1.21.5 runtime
- Rust stable toolchain
- Comprehensive development tools (git, vim, nano, emacs)
- Package managers (pip, pipenv, poetry, npm, yarn, pnpm, cargo)
- Code quality tools (black, flake8, mypy, eslint, prettier)
- Testing frameworks (pytest)
- Process management (pm2, supervisor)
- Database clients (PostgreSQL, MySQL, Redis)
- Cloud tools (AWS CLI)
- Docker CLI for Docker-in-Docker scenarios
- GitHub CLI (gh)
- SSH server configuration for remote development
- Docker Compose setup with volume persistence
- Automated release management with release-please
- GitHub Actions CI/CD pipeline
- Multi-architecture Docker image builds (amd64, arm64)
- Security scanning with Trivy
