# Publishing WinUtilKLENN

Step-by-step guide to publish this repository to GitHub: create the repo, push with HTTPS or SSH, tag the release, and publish the release notes.

## 0. Prerequisites

- A GitHub account (https://github.com)
- Git installed locally (this repo is already initialized on `main` with the `v2.4.1` tag)

The repository **must exist on GitHub before the push works** — Git refuses to push to a repo that doesn't exist yet.

## 1. Create the repository

1. Go to **https://github.com/new**
2. **Repository name:** `WinUtilKLENN`
3. Choose **Public** or **Private** (your call)
4. **Do NOT** tick "Add a README", ".gitignore", or "license" — this repo already contains all of them. An empty repo avoids merge conflicts on first push.
5. Click **Create repository**

## 2. Choose a transport

### Option A — HTTPS (easiest, recommended)

HTTPS uses **Git Credential Manager** (GCM). On the first push from your terminal it opens a browser login window once; afterwards it remembers.

```bash
# point the remote at the HTTPS URL (if it isn't already)
git remote set-url origin https://github.com/sanguirIS/WinUtilKLENN.git

# push the branch and the tag
git push -u origin main --tags
```

### Option B — SSH (no password prompts once set up)

Requires an SSH key registered with GitHub.

```bash
# 1. Generate a key (only if you don't already have one)
ssh-keygen -t ed25519 -C "sanguirIS"
#    press Enter to accept the default location (~/.ssh/id_ed25519)

# 2. Print the public key, then add it at:
#    https://github.com/settings/ssh/new
cat ~/.ssh/id_ed25519.pub

# 3. Verify the key works
ssh -T git@github.com
#    expect: "Hi sanguirIS! You've successfully authenticated..."

# 4. Point the remote at the SSH URL (if it isn't already)
git remote set-url origin git@github.com:sanguirIS/WinUtilKLENN.git

# 5. Push the branch and the tag
git push -u origin main --tags
```

## 3. Create the GitHub release

> **Optional: automatic releases.** If the workflow `.github/workflows/release.yml` is in the repo, the release is **created automatically** when you push a `v*` tag — the body is taken from `RELEASE_NOTES.md` at that tag, and the release appears on the Releases page within a minute. No manual step needed.

If you don't use the auto-release workflow, create it manually:

1. Go to **https://github.com/sanguirIS/WinUtilKLENN/releases/new**
2. **Tag:** `v2.4.1` (select it from the dropdown — the annotated tag is already in the repo)
3. **Title:** `WinUtilKLENN v2.4.1`
4. **Body:** paste the contents of [RELEASE_NOTES.md](RELEASE_NOTES.md)
5. Click **Publish release**

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `remote: Repository not found.` | Repo doesn't exist, is under a different name, or you're unauthenticated | Create it at github.com/new with the exact name `WinUtilKLENN`; confirm you're logged into the account that owns it |
| `Permission denied (publickey).` | No SSH key registered with GitHub | Do Option B steps 1–3 (generate, add to github.com/settings/ssh/new, test) |
| Push prompts for a username/password | HTTPS without GCM | Install Git Credential Manager, or use Option B (SSH) |
| `could not read Username for 'https://github.com'` | No credential helper configured | Set `git config --global credential.helper manager`, then push again |

## After publishing

- The CI workflow (`.github/workflows/sanity-check.yml`) runs automatically on every push/PR touching `WinUtilKLENN.cmd`.
- The badges at the top of the README (CI status, license) light up once the repo is public.
- Future releases: bump the version in `WinUtilKLENN.cmd` (see [CONTRIBUTING.md](CONTRIBUTING.md) §8), update `RELEASE_NOTES.md`, then:

```bash
git tag -a vX.Y.Z -m "WinUtilKLENN vX.Y.Z"
git push origin main --tags
```

and repeat section 3 with the new tag.
