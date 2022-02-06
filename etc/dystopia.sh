#!/usr/bin/env bash
set -euox pipefail

METAMOD_VERSION=1145
SOURCEMOD_VERSION=6528

function update() {
  "${STEAMCMDDIR}/steamcmd.sh" \
    +force_install_dir "${GAME_DIR}" \
    +login anonymous \
    +app_update 17585 \
    +quit
}

if [ ! -f "${GAME_DIR}/.installed" ]; then
  update
  wget -qO- "https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git${METAMOD_VERSION}-linux.tar.gz" | tar xvzf - -C "${GAME_DIR}" &&
    rm "${GAME_DIR}/addons/metamod_x64.vdf"
  # Install Sourcemod (comment out for tournament servers)
  wget -qO- "https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git${SOURCEMOD_VERSION}-linux.tar.gz" | tar xvzf - -C "${GAME_DIR}"
  touch "${GAME_DIR}/.installed"
else
  echo "Already installed."
  update
fi

"${GAME_DIR}/bin/srcds_run.sh" -port "${GAME_PORT}" -clientport "${CLIENT_PORT}" -game "${GAME_DIR}/dystopia" ${GAME_ARGS}
