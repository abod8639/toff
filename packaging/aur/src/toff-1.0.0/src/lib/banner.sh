#!/usr/bin/env bash
# toff — banner.sh
# ASCII art banner with terminal animation.
# All functions prefixed with toff_ to avoid namespace collisions.

# ── Colors (exported for use by other modules) ─────────────────────────────
toff_colors() {
    RED='\033[0;31m'
    BRED='\033[1;31m'
    GREEN='\033[0;32m'
    BYELLOW='\033[1;33m'
    BCYAN='\033[1;36m'
    GRAY='\033[0;90m'
    NC='\033[0m'
}
toff_colors

toff_show_banner() {
    # No animation if stdout is not a terminal
    if [[ ! -t 1 ]]; then
        cat <<'EOF'
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
   `\\    ``    `-'~x__J    j'  >
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
   `\\    ``    `-'~x__J    j'  >
     ``                   ,/ ,^'
                          f__J
EOF

    _toff_print_frame() {
        local highlight_idx="$1"
        local text1_style="$2"
        local text2_style="$3"
        local art_style="$4"

        local i
        for i in {0..25}; do
            local line="${art_lines[$i]:-}"
            if [[ "$i" -eq "$highlight_idx" ]]; then
                printf '%b%s%b' "${BCYAN}" "$line" "${NC}"
            else
                printf '%b%s%b' "${art_style}" "$line" "${NC}"
            fi

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
    trap 'printf "\033[?25h"; exit 1' INT TERM

    local draw_style="${GRAY}"

    # Draw art line-by-line
    local i
    for i in {0..25}; do
        printf '%b%s%b\n' "${draw_style}" "${art_lines[$i]:-}" "${NC}"
        sleep 0.02
    done

    # Move up to start animation
    printf "\033[26A"

    # Scanning sweep
    local idx
    for idx in {0..25}; do
        _toff_print_frame "$idx" "${GRAY}" "${GRAY}" "${GREEN}"
        sleep 0.04
        printf "\033[26A"
    done

    # Flash alert 3 times
    local k
    for k in {1..3}; do
        _toff_print_frame "-1" "${GRAY}" "${GRAY}" "${GREEN}"
        sleep 0.15
        printf "\033[26A"
        _toff_print_frame "-1" "${BRED}" "${BYELLOW}" "${GREEN}"
        sleep 0.15
        if (( k < 3 )); then
            printf "\033[26A"
        fi
    done

    # Restore cursor
    printf "\033[?25h"
    trap - INT TERM
}
