FROM resin/armv7hf-debian-qemu

ENV DEBIAN_FRONTEND noninteractive
ENV PROMETHEUS_VERSION 1.1.3

RUN apt-get update && \
    apt-get install -yq \
            curl

RUN curl -Ls https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-armv7.tar.gz | tar -xzC /tmp/ && \
    cd /tmp/prometheus-$PROMETHEUS_VERSION.linux-armv7 && \
    mkdir -p /etc/prometheus && \
    mv prometheus /bin/prometheus && \
    mv promtool /bin/promtool && \
    mv console_libraries /etc/prometheus/ && \
    mv consoles /etc/prometheus/ && \
    cd /tmp && rm -rf prometheus-$PROMETHEUS_VERSION.linux-armv7

COPY requirements.txt /tmp/requirements.txt

RUN apt-get install -f python-pip python-dev build-essential\
  && pip install --upgrade pip\
  && pip install -r /tmp/requirements.txt

COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY app/app.py /opt/app.py


COPY temperature.service /lib/systemd/system/
RUN chmod 644 /lib/systemd/system/temperature.service

EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "-config.file=/etc/prometheus/prometheus.yml", \
             "-storage.local.path=/prometheus", \
             "-web.console.libraries=/etc/prometheus/console_libraries", \
             "-web.console.templates=/etc/prometheus/consoles" ]
