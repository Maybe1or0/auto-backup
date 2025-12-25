# GitHub AutoBackup

Automated daily backup system for GitHub repositories, designed to run on a
Raspberry Pi as a secure, offline-capable mirror.

## Objectives
- Detect newly created GitHub repositories
- Fetch new commits automatically
- Maintain a local backup (mirror or standard clone)
- Run unattended using systemd timers
- Provide reproducible documentation

## Project Structure
- `src/` : core backup logic
- `config/` : user configuration
- `systemd/` : service and timer units
- `doc/` : LaTeX technical documentation
- `logs/` : execution logs

## Requirements
- git
- gh (GitHub CLI)
- SSH access to GitHub

## Quick Start

```bash
./scripts/install.sh