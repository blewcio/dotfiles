# Private Submodule Setup Guide

This guide walks through setting up the private configuration submodule for this dotfiles repository.

## Quick Start (New Machine)

If you're cloning dotfiles on a new machine and the submodule is already set up:

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

## Initial Setup (First Time)

### Step 1: Create Private GitHub Repository

1. Go to GitHub and create a **private** repository named `dotfiles-private`
2. **Important**: Do NOT initialize it with README, .gitignore, or license
3. Copy the SSH clone URL: `git@github.com:YOUR_USERNAME/dotfiles-private.git`

### Step 2: Push Local Private Repo to GitHub

```bash
cd ~/dotfiles/private
git remote add origin git@github.com:YOUR_USERNAME/dotfiles-private.git
git push -u origin master
```

### Step 3: Convert to Submodule

Now we need to convert the `private/` directory into a proper git submodule:

```bash
cd ~/dotfiles

# Remove the private directory (it's backed up on GitHub now)
rm -rf private

# Add it back as a submodule
git submodule add git@github.com:YOUR_USERNAME/dotfiles-private.git private

# Commit the submodule configuration
git add .gitmodules private
git commit -m "Add private configuration as submodule"
git push
```

### Step 4: Optional - Add NAS Backup Remote

For additional redundancy, add your NAS as a secondary remote:

```bash
cd ~/dotfiles/private

# Create a bare git repo on your NAS first:
# ssh to NAS and run: git init --bare ~/git-repos/dotfiles-private.git

# Add NAS as remote
git remote add nas ssh://blazej-admin@synology:2025/path/to/git-repos/dotfiles-private.git

# Push to NAS
git push nas master
```

## Daily Usage

### Making Changes to Private Config

```bash
cd ~/dotfiles/private

# Edit files
vim shell/private.sh

# Commit and push
git add .
git commit -m "Update API keys"
git push origin master
git push nas master  # Optional: backup to NAS
```

### Adding Claude Skills

```bash
cd ~/dotfiles/private/skills

# Create a new skill directory
mkdir my-custom-skill
# Add skill files
# ...

# Commit
cd ~/dotfiles/private
git add skills/
git commit -m "Add custom skill: my-custom-skill"
git push origin master
```

### Updating Submodule on Another Machine

If you've made changes on one machine and want to pull them on another:

```bash
cd ~/dotfiles
git submodule update --remote private

# Or, from within the submodule:
cd ~/dotfiles/private
git pull origin master
```

### Updating Main Dotfiles with Latest Submodule

When the submodule has new commits, the parent repo needs to be updated:

```bash
cd ~/dotfiles
git add private
git commit -m "Update private submodule reference"
git push
```

## Troubleshooting

### Submodule is empty after clone

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

### Detached HEAD in submodule

```bash
cd ~/dotfiles/private
git checkout master
```

### Accidentally committed secrets to main repo

```bash
# Remove from git history (use with caution!)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/secret/file' \
  --prune-empty --tag-name-filter cat -- --all

# Then force push (WARNING: rewrites history)
git push origin --force --all
```

## Structure

```
~/dotfiles/
├── private/                    # Git submodule (private repo)
│   ├── .git/                   # Separate git repository
│   ├── README.md
│   ├── shell/
│   │   └── private.sh         # Sourced by shellrc.sh
│   └── skills/                 # Claude agent custom skills
│       └── .gitkeep
├── .gitmodules                 # Submodule configuration
├── shell.d/                    # Public shell configs
│   └── private.sh             # Old location (kept for backward compat)
└── ...
```

## Security Best Practices

1. **Never** commit API keys or secrets to the main dotfiles repo
2. **Always** verify private repo is set to private on GitHub
3. **Rotate** any credentials that were accidentally exposed
4. **Review** commits before pushing to ensure no secrets leaked
5. **Consider** encrypting the private repo with git-crypt for additional security
6. **Use** SSH keys (not HTTPS) for GitHub access to private repos
7. **Backup** regularly to NAS or other secure location

## Migration Notes

- The old `shell.d/private.sh` is now gitignored but kept for backward compatibility
- New private configs should go in `private/shell/private.sh`
- Both locations are sourced by `shellrc.sh`, so both work
- Eventually, you can delete `shell.d/private.sh` once migration is complete
