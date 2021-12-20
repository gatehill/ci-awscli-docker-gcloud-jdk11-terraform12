FROM adoptopenjdk:11-jdk-hotspot

ARG AWSCLI_VER="1.16.118"
ARG COMPOSE_VER="1.23.2"
ARG TERRAFORM_VER="0.12.31"

# Set up directories
RUN mkdir -p ~/.local/bin

RUN apt-get update -y && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        gnupg-agent \
        software-properties-common \
        unzip

# Install AWS CLI
RUN apt-get install -y python3-pip && \
    pip install awscli==${AWSCLI_VER} --upgrade --user

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable" && \
    apt-get update -y && \
    apt-get install -y docker-ce-cli

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install gcloud
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh --quiet

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin:$HOME/.local/bin

# Install kubectl
RUN export PATH=$PATH:/usr/local/gcloud/google-cloud-sdk/bin \
  && gcloud components install kubectl --quiet

# Install Helm
RUN export PATH=$PATH:$HOME/.local/bin/ \
  && cd /tmp \
  && curl -O -L https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz \
  && tar xvf helm-v3.0.2-linux-amd64.tar.gz \
  && cd $HOME/.local/bin \
  && mv /tmp/linux-amd64/helm . \
  && chmod u+x helm

# Install Terraform
RUN mkdir -p ~/.local/bin && \
    cd ~/.local/bin && \
    curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    unzip *.zip && \
    rm *.zip && \
    chmod +x terraform
