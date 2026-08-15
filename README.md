# toff

A lightweight Bash utility to schedule system shutdowns based on a countdown timer or the duration of online media (YouTube, SoundCloud, etc.).

<p align="center">
  <a href="https://www.gnu.org/software/bash/"><img src="https://img.shields.io/badge/shell-bash-4EAA25.svg" alt="Bash" /></a>
  <a href="https://github.com/abod8639/toff"><img src="https://img.shields.io/badge/github-1000000?style=social&logo=github" alt="Github" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" /></a>
  <a href="https://aur.archlinux.org/packages/toff"><img src="https://img.shields.io/aur/version/toff" alt="AUR version" /></a>
  <a href="https://www.kernel.org"><img src="https://img.shields.io/badge/platform-linux-blue.svg" alt="Platform" /></a>
</p>

---

## Features

- **Flexible Time Formats:** Supports `H.MM`, `MM`, `HH:MM`, and `HH:MM:SS`.
- **Media-Aware Shutdown:** Fetches the duration of video/playlist URLs (using `yt-dlp`) and schedules a shutdown accordingly.
- **Custom Buffer:** Add extra cushion time after media ends (e.g., `+5` minutes).
- **Rich Terminal UI:** Displays a custom ASCII scanning & flashing animation before initiation.
- **Shell Completions:** Native completion support for Bash, Zsh, and Fish shells.
- **Safety First:** Prevents multiple overlapping timers and provides a quick cancel command.
- **Cross-Init Compatibility:** Works out-of-the-box with `systemd`, `OpenRC`, `Runit`, `s6`, and `SysV` init systems.

---

## Installation

### Arch Linux (AUR)

You can install `toff` directly from the AUR using your favorite AUR helper:

```bash
yay -S toff
```




### Other Linux Distributions (From Source)

Clone the repository and use the `Makefile`:

```bash
git clone https://github.com/abod8639/toff.git
cd toff

# System-wide (installs to /usr/local/bin)
sudo make install
```

---

## Usage

```bash
toff [OPTIONS] <TIME|URL>
toff --cancel
```

### Options

| Option | Long Option | Description | Default |
| :--- | :--- | :--- | :--- |
| `-b <min>` | `--buffer <min>` | Extra time added after media ends | `2` |
| `-p` | `--playlist` | Force playlist mode (sums all video durations) | Auto |
| | `--no-playlist` | Disable playlist auto-detection | |
| `-n` | `--no-banner` | Skip the banner animation | |
| `-q` | `--quiet` | Suppress the countdown display | |
| `-c` | `--cancel` | Cancel any pending toff shutdown | |
| `-v` | `--version` | Print version and exit | |
| `-h` | `--help` | Show help information | |

### Examples

#### 1. Timer Mode
```bash
toff 90       # Shutdown in 90 minutes
toff 1.30     # Shutdown in 1 hour and 30 minutes
toff 1:15:00  # Shutdown in 1 hour, 15 minutes, and 0 seconds
```

#### 2. Media URL Mode (requires `yt-dlp`)
```bash
toff "https://www.youtube.com/watch?v=dQw4w9WgXcQ"   # Shuts down after video ends + 2m buffer
toff -b 10 "https://soundcloud.com/..."             # Shuts down after track ends + 10m buffer
toff --playlist "https://youtube.com/playlist?..."   # Sums up the entire playlist duration
toff --no-playlist "https://youtube.com/playlist?..." # Force single video mode, ignore auto-detect
```

#### 3. UI & Display Customization
```bash
toff -n 45      # Start a 45-minute timer without showing the ASCII banner
toff -q 1.30    # Start a 1h 30m timer quietly (suppresses the countdown ticker)
toff -nq 30     # Start a 30-minute timer quietly and without the banner
```

#### 4. Cancel Pending Timer
```bash
toff -c   # Stop any pending scheduled shutdown
```

#### 5. Help & Version Information
```bash
toff -h         # Show detailed help instructions and options
toff -v         # Print the installed version of toff
```
---

## Dependencies

- **System:** A Linux system with one of the supported init systems (`systemd`, `OpenRC`, `Runit`, `s6`, `SysV`).
- **Build Tools:** `make` (required for manual installation).
- **Optional (for media URLs):** [yt-dlp](https://github.com/yt-dlp/yt-dlp)

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
