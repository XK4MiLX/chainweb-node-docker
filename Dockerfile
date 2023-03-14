# syntax=docker/dockerfile:experimental
# Run as
# --ulimit nofile=64000:64000
# BUILD PARAMTERS
FROM ubuntu:20.04
# install prerequisites
RUN apt-get update \
    && apt-get install -y libtbb2 libgflags2.2 libsnappy1v5 curl xxd openssl binutils locales jq \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
# Install chainweb applications
WORKDIR /chainweb
RUN PACKAGE=$(curl --silent "https://api.github.com/repos/kadena-io/chainweb-node/releases/latest" | jq -r .assets[0].browser_download_url) && \
echo "Downloading file: ${PACKAGE}" && \
curl -Ls "${PACKAGE}" | tar -xz
COPY check-reachability.sh .
COPY run-chainweb-node.sh .
COPY initialize-db.sh .
COPY chainweb.yaml .
COPY check-health.sh .
RUN chmod 755 check-reachability.sh run-chainweb-node.sh initialize-db.sh check-health.sh
RUN mkdir -p /data/chainweb-db
RUN mkdir -p /root/.local/share/chainweb-node/mainnet01/
STOPSIGNAL SIGTERM
EXPOSE 443
EXPOSE 80
EXPOSE 1789
EXPOSE 1848
HEALTHCHECK --start-period=10m --interval=1m --retries=5 --timeout=10s CMD ./check-health.sh
CMD ./run-chainweb-node.sh
