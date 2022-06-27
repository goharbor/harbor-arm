FROM python:3.8.5-slim

ENV HELM_EXPERIMENTAL_OCI=1
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

COPY ./migrate_chart.py ./migrate_chart.sh /

RUN ARCH= && dpkgArch="$(uname -m)" \
  && case "${dpkgArch}" in \
    x86_64) ARCH='x64'; curl -fsSL -o / https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz \
    tar zxvf /helm-v3.2.4-linux-amd64.tar.gz && \
    pip install click==7.1.2 && \
    pip install requests==2.24.0 && \
    chmod +x /migrate_chart.sh ./migrate_chart.py ;; \
    aarch64) ARCH='arm64'; curl -fsSL -o / https://get.helm.sh/helm-v3.2.4-linux-arm64.tar.gz \
    tar zxvf /helm-v3.2.4-linux-arm64.tar.gz && \
    pip install click==7.1.2 && \
    pip install requests==2.24.0 && \
    chmod +x /migrate_chart.sh ./migrate_chart.py ;; \
    ppc64el) ARCH='ppc64le'; ;; \
    s390x) ARCH='s390x'; ;; \
    arm64) ARCH='arm64'; curl -fsSL -o / https://get.helm.sh/helm-v3.2.4-linux-arm64.tar.gz \
    tar zxvf /helm-v3.2.4-linux-arm64.tar.gz && \
    pip install click==7.1.2 && \
    pip install requests==2.24.0 && \
    chmod +x /migrate_chart.sh ./migrate_chart.py ;; \
    armhf) ARCH='armv7l'; ;; \
    i386) ARCH='x86'; ;; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac

ENTRYPOINT [ "/migrate_chart.py" ]