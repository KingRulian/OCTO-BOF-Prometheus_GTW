FROM debian:11-slim

RUN apt-get update && apt-get install -y curl bash vim && rm -rf /var/lib/apt/lists/* && \
    useradd -ms /bin/bash octo

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

RUN chmod +x ./kubectl && mv ./kubectl /usr/local/bin

USER octo

WORKDIR /scripts

COPY scripts/*.sh .

ENTRYPOINT [ "/scripts/verify_tls_secret.sh" ]
