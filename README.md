# GitHub AutoBackup

Systeme de sauvegarde automatique des depots GitHub d'un utilisateur, concu pour
fonctionner sur un Raspberry Pi (Linux Debian) sans interface graphique.

## Objectif
- Detecter les nouveaux depots GitHub
- Mettre a jour les depots existants
- Conserver une copie locale (clone normal ou miroir)
- Planifier l'execution via systemd
- Fournir une documentation technique LaTeX

## Architecture
- `config/` : configuration utilisateur (config.env)
- `src/` : modules Bash (API GitHub, operations Git, logs, prerequis)
- `systemd/` : service et timer systemd
- `scripts/` : installation et activation
- `logs/` : journalisation (backup.log)
- `doc/` : documentation LaTeX
- `tests/` : tests simples

## Installation
1. Installer les dependances et activer le timer :
   `./scripts/install.sh`
2. Modifier la configuration :
   `config/config.env`
3. Verifier l'authentification GitHub CLI :
   `gh auth status`

L'installation utilise les fichiers systemd du dossier `systemd/` et active un
timer quotidien.

## Execution manuelle
```
./src/backup.sh
```

Les logs sont ecrits dans `logs/backup.log`.

## Documentation LaTeX
La documentation est dans `doc/`. Pour compiler :

```
cd doc
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```
