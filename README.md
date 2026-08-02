<div align="center">

```
                       ,~"~.
     ,_.,              > ::::
    /   \%~,          <, ?::;
    \0 0/   "q         l_  f
     |"|    //       ,__}--{_.
   __.T._  //       /         }
,p}---V--{d'       /          !
!\ ---I---        /  ,    1  J;
 \\ --^--  _,___.'  /1    !  Y
  `b=====%/_l_____.' |    l /
     }={             l     f
   (`~=~')           I===I=I
```

# toff

**A CLI shutdown timer — with YouTube & media URL support**

[![AUR](https://img.shields.io/aur/version/toff?label=AUR)](https://aur.archlinux.org/packages/toff)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash%204%2B-green)](src/toff)

</div>

---

## Features

- ⏱️ **Manual timer** — set shutdown time in hours/minutes
- 🎥 **YouTube support** — paste a video URL to shut down when it ends
- 📋 **Playlist support** — sums the entire playlist duration automatically
- 🎵 **Any media URL** — works with SoundCloud, Vimeo, and 1000+ sites via [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- ⏸️ **Buffer time** — adds extra minutes after media ends (default: 2 min)
- 🔄 **Cross-distro** — works on systemd, OpenRC, runit, s6, and SysV
- ❌ **Cancel anytime** — `toff --cancel` or press `Ctrl+C` during countdown
- 🐚 **Shell completions** — bash, zsh, fish

---

## Installation

### Arch Linux (AUR)

```bash
# Using yay
yay -S toff

# Using paru
paru -S toff

# Manually
git clone https://aur.archlinux.org/toff.git
cd toff && makepkg -si
```

### From Source (any Linux distro)

```bash
git clone https://github.com/abod8639/toff.git
cd toff

# Install to /usr/local (default)
sudo make install

# Or install to /usr
sudo make install PREFIX=/usr
```

### Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| `bash >= 4.0` | ✅ Always | Shell runtime |
| `yt-dlp` | ✅ For URL mode | Fetch media duration |
| `util-linux` | ✅ Always | `getopt`, `shutdown` |
| `libnotify` | ⭕ Optional | Desktop notifications |
| `at` | ⭕ Optional | Alternative scheduler |

---

## Usage

```
toff [OPTIONS] <TIME|URL>
toff --cancel
```

### Time Formats

| Format | Example | Meaning |
|--------|---------|---------|
| `H.MM` | `1.30` | 1 hour 30 minutes |
| `MM` | `90` | 90 minutes |
| `HH:MM` | `1:30` | 1 hour 30 minutes |
| `HH:MM:SS` | `1:30:00` | 1 hour 30 minutes |

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `-b, --buffer MINUTES` | `2` | Extra time after media ends |
| `-p, --playlist` | auto | Force playlist mode |
| `--no-playlist` | — | Disable playlist detection |
| `-n, --no-banner` | — | Skip ASCII art banner |
| `-q, --quiet` | — | No countdown display |
| `-c, --cancel` | — | Cancel pending shutdown |
| `-v, --version` | — | Print version |
| `-h, --help` | — | Show help |

### Examples

```bash
# Shut down in 1 hour 30 minutes
toff 1.30

# Shut down in 90 minutes
toff 90

# Shut down after a YouTube video ends (+ 2 min buffer)
toff https://youtu.be/dQw4w9WgXcQ

# Shut down after a video with a 5-minute buffer
toff --buffer 5 https://youtu.be/dQw4w9WgXcQ

# Shut down after an entire YouTube playlist
toff --playlist 'https://youtube.com/playlist?list=PLxxxxxx'

# Shut down after a SoundCloud track
toff https://soundcloud.com/artist/track

# Cancel a pending shutdown
toff --cancel
```

---

## How It Works

### Shutdown Scheduling

`toff` tries the following strategies in order, falling back automatically:

| Priority | Strategy | Survives Terminal Close | Precision |
|----------|----------|------------------------|-----------|
| 1 | `shutdown -P +N` | ✅ Yes | ±1 minute |
| 2 | `systemd-run --on-active` | ✅ Yes | ±1 second |
| 3 | `at` command | ✅ Yes | ±1 minute |
| 4 | `sleep` + `poweroff` | ✅ Yes (via `disown`) | ±1 second |

### URL Mode Flow

```
toff <URL>
    │
    ├─ Auto-detect: is URL a playlist?
    │
    ├─ yt-dlp --get-duration <URL>
    │   └─ Returns: HH:MM:SS per video
    │
    ├─ Parse duration(s) → total seconds
    ├─ Add buffer (default: 2 min)
    │
    ├─ Display: media duration + buffer + expected poweroff time
    ├─ Schedule shutdown
    └─ Show live countdown
```

---

## File Structure

```
toff/
├── src/
│   ├── toff                # Main executable
│   └── lib/
│       ├── banner.sh       # ASCII art + animation
│       ├── countdown.sh    # Countdown display + formatting
│       ├── media.sh        # yt-dlp URL integration
│       ├── parser.sh       # Time input parser
│       └── shutdown.sh     # Cross-distro shutdown scheduler
│
├── completions/
│   ├── toff.bash           # Bash completion
│   ├── toff.zsh            # Zsh completion
│   └── toff.fish           # Fish completion
│
├── man/
│   └── toff.1              # Man page
│
├── packaging/
│   └── aur/
│       ├── PKGBUILD        # Arch Linux AUR package
│       └── .SRCINFO
│
├── Makefile                # Install / uninstall
├── LICENSE                 # MIT
└── README.md
```

---

## Configuration for Non-systemd Systems

On systemd (default Arch Linux), the active user can poweroff without `sudo` via **logind** — no extra setup needed.

On **OpenRC / runit / SysV**, add the following to `/etc/sudoers` via `visudo`:

```
%wheel ALL=(ALL) NOPASSWD: /usr/bin/poweroff, /usr/bin/shutdown, /usr/bin/halt
```

---

## Shell Completions

Completions are installed automatically via `make install`. To enable manually:

```bash
# Bash — add to ~/.bashrc:
source /usr/share/bash-completion/completions/toff

# Zsh — add to fpath in ~/.zshrc:
fpath=(/usr/share/zsh/site-functions $fpath)

# Fish — auto-loaded from vendor_completions.d
```

---

## Contributing

Pull requests are welcome! Please:
1. Fork the repo and create a feature branch
2. Keep functions in the appropriate `src/lib/*.sh` file
3. Prefix all public functions with `toff_`
4. Test with `make check` before submitting

---

## License

MIT © [abod8639](https://github.com/abod8639)
