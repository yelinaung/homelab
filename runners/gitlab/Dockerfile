FROM debian:bookworm-slim@sha256:1209d8fd77def86ceb6663deef7956481cc6c14a25e1e64daec12c0ceffcc19d

ARG TERRAFORM_VERSION=1.15.3
ARG TFLINT_VERSION=0.62.1
ARG MISE_VERSION=2026.5.15

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        unzip \
        xz-utils && \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && rm /tmp/terraform.zip && \
    curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" -o /tmp/tflint.zip && \
    unzip /tmp/tflint.zip -d /usr/local/bin && rm /tmp/tflint.zip && \
    curl -fsSL "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/mise-v${MISE_VERSION}-linux-x64" -o /usr/local/bin/mise && \
    chmod +x /usr/local/bin/mise && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV MISE_DATA_DIR=/usr/local/share/mise
ENV PATH="/usr/local/share/mise/shims:${PATH}"

HEALTHCHECK NONE
