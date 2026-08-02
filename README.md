# toff 

A lightweight, animated Bash utility to schedule system shutdowns based on a countdown timer or the duration of online media (YouTube, SoundCloud, etc.).
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
---

## Features

- **Flexible Time Formats:** Supports `H.MM`, `MM`, `HH:MM`, and `HH:MM:SS`.
- **Media-Aware Shutdown:** Fetches duration of video/playlist URLs (using `yt-dlp`) and schedules shutdown accordingly.
- **Custom Buffer:** Add extra cushion time after media ends (e.g. `+5` minutes).
- **Rich Terminal UI:** Displays a custom ASCII scanning & flashing animation before initiation.
- **Safety First:** Prevents multiple overlapping timers and provides a quick cancel command.

---

## Installation

Clone the repository and run:

```bash
# System-wide (installs to /usr/local/bin)
sudo make install

# System-wide (alternative path /usr/bin)
sudo make install PREFIX=/usr

# Local user-only (installs to ~/.local/bin)
make install PREFIX=$HOME/.local
```

---

## Usage

```bash
toff [OPTIONS] <TIME|URL>
toff --cancel
```

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
```

#### 3. Cancel Timer
```bash
toff --cancel  # Stop any scheduled shutdown
```

---

## Dependencies

- **System:** `systemd` (uses `shutdown`)
- **Optional (for media URLs):** [yt-dlp](https://github.com/yt-dlp/yt-dlp)

---

## License

This project is licensed under the MIT License. See [LICENSE](file:///home/dexter/bash/shotdown_poweroff/LICENSE) for details.
