#!/bin/bash
set -e

# ============================================
# Conan Exiles Enhanced Dedicated Server - Entrypoint
# ============================================

GAME_DIR="/empyrion-server"
SERVER_EXE="${GAME_DIR}/DedicatedServer/EmpyrionDedicated.exe"
STEAM_APP_ID=530870
WORKSHOP_APP_ID=383120
STEAMCMD_BIN="${STEAMCMD_BIN:-/steamcmd/steamcmd.sh}"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[Empyrion]${NC} $1"; }
warn() { echo -e "${YELLOW}[Empyrion]${NC} $1"; }
error() { echo -e "${RED}[Empyrion]${NC} $1"; }

# ============================================
# 1. Download / Update game
# ============================================
if [ ! -f "$SERVER_EXE" ]; then
    log "Game not found. Downloading Empyrion: Galactic Survival Dedicated Server (~1.9GB)..."
    log "This may take 10-30 minutes on first run."
else
    log "Game found. Checking for updates..."
fi

"$STEAMCMD_BIN" \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir "$GAME_DIR" \
    +login anonymous \
    +app_update $STEAM_APP_ID \
    +quit

if [ ! -f "$SERVER_EXE" ]; then
    error "Download failed! Retrying in 10 seconds..."
    sleep 10
    "$STEAMCMD_BIN" \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir "$GAME_DIR" \
        +login anonymous \
        +app_update $STEAM_APP_ID validate \
        +quit
fi

if [ ! -f "$SERVER_EXE" ]; then
    error "Download failed after retry. Exiting."
    exit 1
fi

log "Game files ready!"

# ============================================
# 5. Start server
# ============================================
log "Starting Empyrion: Galactic Survival Dedicated Server..."
log "============================================"

server_args=(
    -batchmode
    -nographics
    -logFile
    Logs/current.log
)
if [ -n "$DEDICATED_YML" ]; then
    server_args+=(
        -dedicated
        "$DEDICATED_YML"
    )
fi

cd "$GAME_DIR/DedicatedServer"
mkdir -p "Logs"

rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 &
export WINEDLLOVERRIDES="mscoree,mshtml="
export DISPLAY=:1

sh -c 'until [ "`netstat -ntl | tail -n+3`" ]; do sleep 1; done
sleep 5 # gotta wait for it to open a logfile
tail -F Logs/current.log ../Logs/*/*.log 2>/dev/null' &
/usr/lib/wine/wine64 ./EmpyrionDedicated.exe "${server_args[@]}" &> Logs/wine.log
