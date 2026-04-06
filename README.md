![Platform](https://img.shields.io/badge/platform-Linux%20(Debian)-blue)
![Device](https://img.shields.io/badge/device-Raspberry%20Pi-red)
![Language](https://img.shields.io/badge/language-Bash-green)
![Automation](https://img.shields.io/badge/automation-systemd-orange)
![GitHub API](https://img.shields.io/badge/API-GitHub-black)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

# GitHub AutoBackup

Automatic backup system for a user's GitHub repositories, designed to run on a Raspberry Pi (Debian Linux) without a graphical interface.

## Objective
- Detect new GitHub repositories
- Update existing repositories
- Maintain a local copy (standard clone or mirror)
- Schedule execution via systemd
- Provide LaTeX technical documentation

## Architecture
- `config/`: user configuration (config.env)
- `src/`: Bash modules (GitHub API, Git operations, logging, prerequisites)
- `systemd/`: systemd service and timer
- `scripts/`: installation and activation
- `doc/`: documentation
- `tests/`: basic tests

## Installation
1. Install dependencies and enable the timer:
   `./scripts/install.sh`
2. Edit the configuration:
   `config/config.env`
3. Verify GitHub CLI authentication:
   `gh auth status`

The installation uses the systemd files located in the `systemd/` directory and enables a daily timer.

## Manual Execution
```sh
./src/backup.sh
```

Logs are written to `logs/backup.log`.

## Documentation
The documentation is located in `doc/`.