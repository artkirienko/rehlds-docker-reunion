FROM debian:buster-slim

ARG rehlds_version=3.7.0.695
ARG metamod_version=1.3.0.128
ARG jk_botti_version=1.43
ARG steamcmd_url=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ARG rehlds_url="https://github.com/dreamstalker/rehlds/releases/download/$rehlds_version/rehlds-dist-$rehlds_version-dev.zip"
ARG metamod_url="https://github.com/theAsmodai/metamod-r/releases/download/1.3.128/metamod_$metamod_version.zip"
ARG amxmod_url="https://www.amxmodx.org/amxxdrop/1.9/amxmodx-1.9.0-git5263-base-linux.tar.gz"
ARG revoice_url="https://teamcity.rehlds.org/guestAuth/downloadArtifacts.html?buildTypeId=Revoice_Publish&buildId=lastSuccessful"
ARG jk_botti_url="http://koti.kapsi.fi/jukivili/web/jk_botti/jk_botti-$jk_botti_version-release.tar.xz"

# Fix warning:
# WARNING: setlocale('en_US.UTF-8') failed, using locale: 'C'.
# International characters may not work.
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales=2.28-10 \
 && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV LC_ALL en_US.UTF-8

# Fix error:
# Unable to determine CPU Frequency. Try defining CPU_MHZ.
# Exiting on SPEW_ABORT
ENV CPU_MHZ=2300

RUN groupadd -r steam && useradd -r -g steam -m -d /opt/steam steam

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ca-certificates=20190110 \
    curl=7.64.0-4+deb10u1 \
    lib32gcc1=1:8.3.0-6 \
    unzip=6.0-23+deb10u1 \
    xz-utils=5.2.4-1 \
    zip=3.0-11+b1 \
 && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/*

USER steam
WORKDIR /opt/steam
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY ./lib/hlds.install /opt/steam

RUN curl -sL "$steamcmd_url" | tar xzvf - \
    && ./steamcmd.sh +runscript hlds.install

# Fix error that steamclient.so is missing
RUN mkdir -p "$HOME/.steam" \
    && ln -s /opt/steam/linux32 "$HOME/.steam/sdk32"

# Fix warnings:
# couldn't exec listip.cfg
# couldn't exec banned.cfg
RUN touch /opt/steam/hlds/valve/listip.cfg
RUN touch /opt/steam/hlds/valve/banned.cfg

# Install reverse-engineered HLDS
RUN curl -sLJO "$rehlds_url" \
    && unzip "rehlds-dist-$rehlds_version-dev.zip" -d "/opt/steam/rehlds" \
    && cp -R /opt/steam/rehlds/bin/linux32/* /opt/steam/hlds/ \
    && rm -rf "rehlds-dist-$rehlds_version-dev.zip" "/opt/steam/rehlds"

# Install Metamod-r
RUN curl -sLJO "$metamod_url" \
    && unzip "metamod_$metamod_version.zip" -d "/opt/steam/metamod" \
    && cp -R /opt/steam/metamod/addons /opt/steam/hlds/valve/ \
    && rm -rf "metamod_$metamod_version.zip" "/opt/steam/metamod" \
    && touch /opt/steam/hlds/valve/addons/metamod/plugins.ini \
    && sed -i 's/dlls\/hl\.so/addons\/metamod\/metamod_i386\.so/g' /opt/steam/hlds/valve/liblist.gam

# Install AMX mod X
RUN curl -sqL "$amxmod_url" | tar -C /opt/steam/hlds/valve/ -zxvf - \
    && cat /opt/steam/hlds/valve/mapcycle.txt >> /opt/steam/hlds/valve/addons/amxmodx/configs/maps.ini \
    && echo 'linux addons/amxmodx/dlls/amxmodx_mm_i386.so' >> /opt/steam/hlds/valve/addons/metamod/plugins.ini

# Install reunion
RUN mkdir -p /opt/steam/hlds/valve/addons/reunion
COPY lib/reunion/bin/Linux/reunion_mm_i386.so /opt/steam/hlds/valve/addons/reunion/reunion_mm_i386.so
COPY lib/reunion/reunion.cfg /opt/steam/hlds/valve/reunion.cfg
COPY lib/reunion/amxx/* /opt/steam/hlds/valve/addons/amxmodx/scripting/
RUN echo 'linux addons/reunion/reunion_mm_i386.so' >> /opt/steam/hlds/valve/addons/metamod/plugins.ini \
    && sed -i 's/Setti_Prefix1 = 5/Setti_Prefix1 = 4/g' /opt/steam/hlds/valve/reunion.cfg

# Install revoice
RUN curl -sL "$revoice_url" -o "revoice.zip" \
    && unzip "revoice.zip" -d "/opt/steam/tmp" \
    && unzip /opt/steam/tmp/revoice_*.zip -d "/opt/steam/revoice" \
    && mkdir /opt/steam/hlds/valve/addons/revoice \
    && cp /opt/steam/revoice/bin/linux32/revoice_mm_i386.so /opt/steam/hlds/valve/addons/revoice/revoice_mm_i386.so \
    && cp /opt/steam/revoice/revoice.cfg /opt/steam/hlds/valve/addons/revoice/revoice.cfg \
    && echo 'linux addons/revoice/revoice_mm_i386.so' >> /opt/steam/hlds/valve/addons/metamod/plugins.ini

# Install jk_botti
RUN curl -sqL "$jk_botti_url" | tar -C /opt/steam/hlds/valve/ -xJ \
    && echo 'linux addons/jk_botti/dlls/jk_botti_mm_i386.so' >> /opt/steam/hlds/valve/addons/metamod/plugins.ini

WORKDIR /opt/steam/hlds

# Copy default config
COPY valve valve

RUN chmod +x hlds_run hlds_linux

RUN echo 70 > steam_appid.txt

EXPOSE 27015
EXPOSE 27015/udp

# Start server
ENTRYPOINT ["./hlds_run", "-timeout 3", "-pingboost 1"]

# Default start parameters
CMD ["+map crossfire", "+rcon_password 12345678"]
