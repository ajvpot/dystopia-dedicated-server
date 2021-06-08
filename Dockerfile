FROM debian:buster-slim AS dystopia

ENV USER steam
ENV HOME "/home/${USER}"
ENV STEAMCMDDIR "${HOME}/steamcmd"
ENV GAME_DIR "dystopia"
ENV GAME_PATH "${HOME}/${GAME_DIR}"

RUN set +x \
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		locales \
		wget \
		libsdl2-2.0-0:i386 

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure --frontend=noninteractive locales

# Install SteamCmd
RUN mkdir -p "${STEAMCMDDIR}" \
	&& mkdir -p "${GAME_PATH}/${GAME_DIR}" \
	&& mkdir -p "${GAME_PATH}" \
	&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C "${STEAMCMDDIR}"

# Install Dystopia
RUN "${STEAMCMDDIR}/steamcmd.sh" \
		+login anonymous \
		+force_install_dir "${GAME_PATH}" \
		+app_update 17585 \
		+quit

# Install MetaMod (comment out for tournament servers)
RUN wget -qO- 'https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1144-linux.tar.gz' | tar xvzf - -C "${GAME_PATH}/${GAME_DIR}" \
	&& rm "${GAME_PATH}/${GAME_DIR}/addons/metamod_x64.vdf"

# Install Sourcemod (comment out for tournament servers)
RUN wget -qO- 'https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6502-linux.tar.gz' | tar xvzf - -C "${GAME_PATH}/${GAME_DIR}"


FROM debian:buster-slim

ARG PUID=1000
ENV USER steam
ENV HOME "/home/${USER}"
ENV STEAMCMDDIR "${HOME}/steamcmd"
ENV GAME_DIR "dystopia"
ENV GAME_PATH "${HOME}/${GAME_DIR}"

RUN set -x \
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6 \
		lib32gcc1 \
		libncurses5:i386 \
		ca-certificates \
		locales \
	&& sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure --frontend=noninteractive locales\
	&& apt-get autoremove -y \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -u "${PUID}" -m "${USER}"

# Copy Dystopia from build
COPY --chown=${PUID}:${PUID} --from=dystopia ${HOME} ${HOME}

# Copy external items
COPY --chown=${PUID}:${PUID} etc/cfg/server.cfg ${GAME_PATH}/${GAME_DIR}/cfg/server.cfg
COPY --chown=${PUID}:${PUID} etc/addons/ ${GAME_PATH}/${GAME_DIR}/addons/

USER ${USER}

WORKDIR ${HOME}

# Game Server environment variables
ENV GAME_MAP "dys_detonate"
ENV GAME_MAXPLAYERS 16
ENV GAME_TICKRATE 66
ENV GAME_ARGS "-game ${GAME_PATH}/${GAME_DIR} +maxplayers ${GAME_MAXPLAYERS} +map ${GAME_MAP} -tickrate ${GAME_TICKRATE} +log on +dys_stats_enabled 0"

ENV LD_LIBRARY_PATH "${GAME_PATH}/bin:${GAME_PATH}/bin/linux32"

RUN mkdir -p "${HOME}/.steam/sdk32" \
	&& ln -s "${STEAMCMDDIR}/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so" \
	&& ln -s "${STEAMCMDDIR}/linux32/steamcmd" "${STEAMCMDDIR}/linux32/steam" \
	&& ln -s "${STEAMCMDDIR}/steamcmd.sh" "${STEAMCMDDIR}/steam.sh"

# Run the server
CMD ${GAME_PATH}/bin/linux32/srcds -port 27016 ${GAME_ARGS}

# Client ports
EXPOSE 27016/tcp
EXPOSE 27016/udp
EXPOSE 27006/udp
