FROM debian:bullseye-slim

ARG NESSUS_SERIAL

ENV NESSUS_URL="https://www.tenable.com/downloads/api/v1/public/pages/nessus/downloads/10852/download?i_agree_to_tenable_license_agreement=true"

RUN adduser --shell /bin/true --uid 1000 --home /opt/nessus  --gecos '' app \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y wget ca-certificates libcap2-bin tzdata \
    && wget -qO /tmp/nessus.deb "${NESSUS_URL}" \
    && apt-get remove -y wget && apt-get clean \
    && dpkg -i /tmp/nessus.deb  \
    && rm /tmp/nessus.deb \
    && setcap "cap_sys_resource+eip" /opt/nessus/sbin/nessusd \
    && setcap "cap_sys_resource+eip" /opt/nessus/sbin/nessus-service \
    && setcap "cap_net_admin,cap_net_raw,cap_sys_resource+eip" /opt/nessus/sbin/nessusd \
    && setcap "cap_net_admin,cap_net_raw,cap_sys_resource+eip" /opt/nessus/sbin/nessus-service \
    && /opt/nessus/sbin/nessuscli fetch --register "${NESSUS_SERIAL}" \
    && chown -R app /opt/nessus \
    && chmod u=rx,g=,o= /opt/nessus/sbin/* \
    && /opt/nessus/sbin/nessusd -R \
    && chown -R app /opt/nessus \
    && chmod u=rx,g=,o= /opt/nessus/sbin/*

WORKDIR /opt/nessus
EXPOSE 8834
USER app
VOLUME [ "/opt/nessus" ]
ENTRYPOINT [ "/opt/nessus/sbin/nessusd", "--no-root" ]
