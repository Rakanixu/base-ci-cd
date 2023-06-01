FROM node:16.15 as node

ENV GCLOUD_VERSION=412.0.0 \
    PATH=${PATH}:/opt/node/bin:/opt/google-cloud-sdk/bin \
    USE_GKE_GCLOUD_AUTH_PLUGIN=True

RUN apt-get update || : && apt-get install python -y

RUN set -ex && \
    curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz -o /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz --verbose && \
    tar -C /opt -xzf /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
    ln -s /opt/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64 /opt/google-cloud-sdk && \
    chown -R root: /opt/google-cloud-sdk
RUN gcloud components install gke-gcloud-auth-plugin

RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -L -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/kubectl

RUN set -ex && \
    wget https://github.com/argoproj/argo/releases/download/v3.4.2/argo-linux-amd64.gz && \
    gunzip argo-linux-amd64.gz && \
    chmod +x ./argo-linux-amd64 && \
    mv ./argo-linux-amd64 /usr/local/bin/argo

RUN curl -fsSL https://get.pulumi.com | sh
RUN mkdir -p /usr/local/pulumi
RUN mv ~/.pulumi/bin /usr/local/pulumi/bin
ENV PATH=${PATH}:/usr/local/pulumi/bin

RUN rm -rf /var/cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*