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
    wget https://github.com/argoproj/argo/releases/download/v3.4.8/argo-linux-amd64.gz && \
    gunzip argo-linux-amd64.gz && \
    chmod +x ./argo-linux-amd64 && \
    mv ./argo-linux-amd64 /usr/local/bin/argo

RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && \
    rm argocd-linux-amd64


RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    apt-get install apt-transport-https --yes && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && \
    apt-get install helm

RUN rm -rf /var/cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*