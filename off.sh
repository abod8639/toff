#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./off H.MM
Examples:
  ./off 1.30   # shutdown after 1 hour 30 minutes
  ./off 0.20   # shutdown after 20 minutes
  ./off 20     # shutdown after 20 minutes
EOF
}

show_banner() {
  # Define colors
  local RED='\033[0;31m'
  local BRED='\033[1;31m'
  local GREEN='\033[0;32m'
  local BGREEN='\033[1;32m'
  local BYELLOW='\033[1;33m'
  local BCYAN='\033[1;36m'
  local GRAY='\033[0;90m'
  local NC='\033[0m'

  # Check if stdout is a terminal for colors and animation
  if [[ ! -t 1 ]]; then
    cat <<'EOF'
                       ,~"~.
     ,_.,              &gt; ::::
    /   \%~,          &lt;, ?::;
    \0 0/   "q         l_  f
     |"|    //       ,__}--{_.
   __.T._  //       /         }
,p}---V--{d'       /          !
!\ ---I---        /  ,    1  J;
 \\ --^--  _,___.'  /1    !  Y
  `b=====%/_l_____.' |    l /
     }={             l     f
   (`~=~')           I===I=I
   p(o_o)            f     }
   \\~^~|            |     }
    \\ ||            l    Y;
     \\||            }    |
      \\|            |    |
       })           ,1    |
      //|           !l   ,l
     //||           ! \    \
    // ||           !  \    \
   pf  d|           l___j.   \
  (X\  {Xy,     ,.-'`--(  `.,'`.
   `\\    ``    `-'~x__J    j'  &gt;
     ``                   ,/ ,^'
                         f__J
EOF
    return
  fi

  local art_lines=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    art_lines+=("$line")
  done <<'EOF'
                       ,~"~.
     ,_.,              &gt; ::::
    /   \%~,          &lt;, ?::;
    \0 0/   "q         l_  f
     |"|    //       ,__}--{_.
   __.T._  //       /         }
,p}---V--{d'       /          !
!\ ---I---        /  ,    1  J;
 \\ --^--  _,___.'  /1    !  Y
  `b=====%/_l_____.' |    l /
     }={             l     f
   (`~=~')           I===I=I
   p(o_o)            f     }
   \\~^~|            |     }
    \\ ||            l    Y;
     \\||            }    |
      \\|            |    |
       })           ,1    |
      //|           !l   ,l
     //||           ! \    \
    // ||           !  \    \
   pf  d|           l___j.   \
  (X\  {Xy,     ,.-'`--(  `.,'`.
   `\\    ``    `-'~x__J    j'  &gt;
     ``                   ,/ ,^'
                         f__J 
EOF

  print_frame() {
    local highlight_idx="$1"
    local text1_style="$2"
    local text2_style="$3"
    local art_style="$4"

    local i
    for i in {0..22}; do
      local line="${art_lines[$i]}"
      
      # Print the ASCII art part
      if [[ "$i" -eq "$highlight_idx" ]]; then
        printf '%b%s%b' "${BCYAN}" "$line" "${NC}"
      else
        printf '%b%s%b' "${art_style}" "$line" "${NC}"
      fi

      # Print the side text for specific lines
      if [[ "$i" -eq 1 ]]; then
        printf '   %bPOWER OFF%b' "${text1_style}" "${NC}"
      elif [[ "$i" -eq 6 ]]; then
        printf '  %bSYSTEM SHUTDOWN%b' "${text2_style}" "${NC}"
      fi

      printf '\n'
    done
  }

  # Hide cursor during animation
  printf "\033[?25l"
  
  # Ensure cursor is restored on interrupt
  trap 'printf "\033[?25h"; exit 1' INT TERM

  local draw_style="${GRAY}"

  # 1. Draw art line-by-line
  local i
  for i in {0..22}; do
    # printf '%b%s%b\n' "${draw_style}" "${art_lines[$i]}" "${NC}"
    sleep 0.03
  done

  # Move up 23 lines to start animation
  printf "\033[23A"

  # 2. Scanning sweep (Cyan pulse)
  local idx
  for idx in {0..22}; do
    print_frame "$idx" "${GRAY}" "${GRAY}" "${GREEN}"
    sleep 0.05
    printf "\033[23A"
  done

  # 3. Flashing text/alert 3 times
  local k
  for k in {1..3}; do
    print_frame "-1" "${GRAY}" "${GRAY}" "${GREEN}"
    sleep 0.15
    printf "\033[23A"
    print_frame "-1" "${BRED}" "${BYELLOW}" "${GREEN}"
    sleep 0.15
    if (( k < 3 )); then
      printf "\033[23A"
    fi
  done

  # Restore cursor
  printf "\033[?25h"
  # Clear trap
  trap - INT TERM
}

show_countdown() {
  local total_seconds="$1"
  local remaining="$total_seconds"

  echo
  echo "Countdown:"
  while (( remaining > 0 )); do
    local mins=$((remaining / 60))
    local secs=$((remaining % 60))
    printf '\r  %02d:%02d' "$mins" "$secs"
    sleep 1
    ((remaining--))
  done
  printf '\n'
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

input="$1"

total_minutes=""

if [[ "$input" =~ ^([0-9]+)\.([0-9]{1,2})$ ]]; then
  hours="${BASH_REMATCH[1]}"
  mins="${BASH_REMATCH[2]}"

  if (( mins >= 60 )); then
    echo "Invalid value: minutes must be less than 60"
    exit 1
  fi

  total_minutes=$(( hours * 60 + mins ))
elif [[ "$input" =~ ^([0-9]+)$ ]]; then
  total_minutes="${BASH_REMATCH[1]}"
else
  echo "Invalid format"
  usage
  exit 1
fi

if (( total_minutes <= 0 )); then
  echo "Time must be greater than zero"
  exit 1
fi

show_banner

echo
hours_display=$(( total_minutes / 60 ))
mins_display=$(( total_minutes % 60 ))
echo "Shutdown scheduled in ${hours_display}h ${mins_display}m"

if [[ $(id -u) -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
  sudo shutdown -P +"$total_minutes" >/dev/null 2>&1
else
  shutdown -P +"$total_minutes" >/dev/null 2>&1
fi

show_countdown "$(( total_minutes * 60 ))"
echo "Shutdown started."
