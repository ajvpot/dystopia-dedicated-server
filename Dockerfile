FROM debian:bullseye-slim
ARG HOME="/root"
ARG STEAMCMDDIR="/steamcmd"
ARG GAME_DIR="/data"

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
	&& mkdir -p "${GAME_DIR}/steamapps" \
	&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C "${STEAMCMDDIR}"
RUN set -x \
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6 \
		lib32gcc-s1 \
		libncurses5:i386 \
		ca-certificates \
		locales \
	&& sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure --frontend=noninteractive locales\
	&& apt-get autoremove -y \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/*U

RUN mkdir -p "${HOME}/.steam/sdk32" \
	&& ln -s "${STEAMCMDDIR}/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so" \
	&& ln -s "${STEAMCMDDIR}/linux32/steamcmd" "${STEAMCMDDIR}/linux32/steam" \
	&& ln -s "${STEAMCMDDIR}/steamcmd.sh" "${STEAMCMDDIR}/steam.sh"

ADD etc/dystopia.sh /etc/dystopia.sh

WORKDIR ${HOME}

ARG GAME_PORT=27016
ARG CLIENT_PORT=27006
ARG GAME_MAXPLAYERS=16
ARG GAME_MAP="dys_detonate"
ARG GAME_TICKRATE=66

ENV GAME_DIR=${GAME_DIR}
ENV GAME_PORT=${GAME_PORT}
ENV CLIENT_PORT=${CLIENT_PORT}
ENV GAME_MAXPLAYERS=${GAME_MAXPLAYERS}
ENV GAME_MAP=${GAME_MAP}
ENV GAME_TICKRATE=${GAME_TICKRATE}
ENV HOME=${HOME}
ENV STEAMCMDDIR=${STEAMCMDDIR}

ENV GAME_ARGS="+maxplayers ${GAME_MAXPLAYERS} +map ${GAME_MAP} -tickrate ${GAME_TICKRATE} +log on +dys_stats_enabled 0"
ENV LD_LIBRARY_PATH="${GAME_DIR}/bin:${GAME_DIR}/bin/linux32:$LD_LIBRARY_PATH"

# Run the server
CMD /etc/dystopia.sh

# Client ports
EXPOSE ${GAME_PORT}/tcp
EXPOSE ${GAME_PORT}/udp
EXPOSE ${CLIENT_PORT}/udp
