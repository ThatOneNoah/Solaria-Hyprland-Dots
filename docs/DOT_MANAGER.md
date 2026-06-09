# SOLARIA Dot Manager

SOLARIA includes a profile manager app named `solaria-dots`.

It lets you:

- Save your current installed rice as a profile.
- Create a blank profile for a new rice.
- Switch between SOLARIA and other profiles.
- Open profile folders so you can edit the files.
- Delete profiles you no longer want.

Profiles live here:

```text
~/.local/share/solaria-dots/profiles
```

Each profile uses this layout:

```text
profile-name/
  profile.conf
  dotfiles/
    .config/
    .local/bin/
    .local/share/
    scripts/
  wallpapers/
```

## Open The App

After running `./install.sh`, launch it from your app launcher as:

```text
SOLARIA Dot Manager
```

You can also run:

```bash
solaria-dots
```

If Rofi, Wofi, or Fuzzel is installed, it opens as a launcher-style menu. Otherwise it works from the terminal.

## Commands

List profiles:

```bash
solaria-dots list
```

Show the active profile:

```bash
solaria-dots current
```

Save the current installed dotfiles as a new profile:

```bash
solaria-dots save my-rice
```

Overwrite an existing saved profile:

```bash
solaria-dots save my-rice --force
```

Create a blank profile folder:

```bash
solaria-dots new clean-rice
```

Switch to a profile:

```bash
solaria-dots switch solaria
solaria-dots switch my-rice
```

Open the profiles folder:

```bash
solaria-dots open
```

Open one profile:

```bash
solaria-dots open my-rice
```

Delete a profile:

```bash
solaria-dots delete my-rice --force
```

## Backups

Every switch moves replaced files into:

```text
~/.rice-backups/solaria-dots/
```

This is intentionally conservative. If a profile replaces `~/.config/hypr`, the previous `~/.config/hypr` is moved into a timestamped backup before the new one is copied in.

## Built-In SOLARIA Profile

The installer creates this profile automatically:

```text
solaria
```

That means you can save another setup and still switch back:

```bash
solaria-dots save my-current-dots
solaria-dots switch solaria
solaria-dots switch my-current-dots
```
