# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0](https://github.com/FrancisVarga/spielen-devcontainer/compare/developer-environment-v0.4.0...developer-environment-v0.5.0) (2025-05-26)


### Features

* Add runtime SSH key setup script and update Dockerfile for SSH configuration ([6edb11a](https://github.com/FrancisVarga/spielen-devcontainer/commit/6edb11a4e9c6e2bcc21af8a986beedb516d3a8a3))
* Enhance container startup script with improved SSH daemon handling and error reporting ([c32e5f5](https://github.com/FrancisVarga/spielen-devcontainer/commit/c32e5f55afe18b15d4a1a89316a757f474879661))
* Improve container startup and SSH service configuration ([64f5cc1](https://github.com/FrancisVarga/spielen-devcontainer/commit/64f5cc1d8607fb9b3fa48b4842ba587d3209e3ae))
* Integrate pyenv and nvm into Docker build and simplify dev tools setup ([1966be8](https://github.com/FrancisVarga/spielen-devcontainer/commit/1966be800e2ee75b621f0db5ca07321d1c446d34))
* Move pyenv dependencies installation earlier in Dockerfile ([ff62a98](https://github.com/FrancisVarga/spielen-devcontainer/commit/ff62a98b493fcad33a2bf97e3e9fa0a0f5472194))
* Update release-please workflow: upgrade actions and simplify config ([58c36e1](https://github.com/FrancisVarga/spielen-devcontainer/commit/58c36e1efb2846d8f78b7ab3b332b2055af36154))


### Bug Fixes

* Comment out Docker image testing steps in workflow ([6a3e06c](https://github.com/FrancisVarga/spielen-devcontainer/commit/6a3e06cd93f1585ca2ae4542de7a81b52f7ae770))
* Improve SSH daemon startup handling and error reporting in container initialization script ([327eea7](https://github.com/FrancisVarga/spielen-devcontainer/commit/327eea7a4b18a4a6560994506720686ea08e1237))
* release and add caching ([e9731d8](https://github.com/FrancisVarga/spielen-devcontainer/commit/e9731d84d5edc3f5826eea97b3191d581a7a7b19))
* Restore and enhance Docker image testing steps in workflow ([02b8812](https://github.com/FrancisVarga/spielen-devcontainer/commit/02b8812090a44eafdc20e66c6e072bbc4f403552))

## [0.4.0](https://github.com/FrancisVarga/spielen-devcontainer/compare/developer-environment-v0.3.0...developer-environment-v0.4.0) (2025-05-26)


### Features

* Add coreutils and sed packages to Dockerfile ([1b7aa21](https://github.com/FrancisVarga/spielen-devcontainer/commit/1b7aa21a22f9739fd6edfe55e7a88dbbf3600065))

## [0.3.0](https://github.com/FrancisVarga/spielen-devcontainer/compare/developer-environment-v0.2.0...developer-environment-v0.3.0) (2025-05-26)


### Features

* feat:  ([f2882cb](https://github.com/FrancisVarga/spielen-devcontainer/commit/f2882cb2c242c4bfa229897abd4223b4424fe302))
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


### Miscellaneous

* **main:** release developer-environment 0.2.0 ([4aa0dca](https://github.com/FrancisVarga/spielen-devcontainer/commit/4aa0dca76390046954fb1d3bb639a1840fc2550f))
* **main:** release developer-environment 0.2.0 ([460d3a4](https://github.com/FrancisVarga/spielen-devcontainer/commit/460d3a48db40704d81eb4c6aceac90a4f29119ae))

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
