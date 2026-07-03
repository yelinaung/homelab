FROM debian:bookworm-slim@sha256:0104b334637a5f19aa9c983a91b54c89887c0984081f2068983107a6f6c21eeb

ARG TERRAFORM_VERSION=1.15.6
ARG TFLINT_VERSION=0.62.1
ARG MISE_VERSION=2026.6.11
# Must match the pinned versions in mise.toml.
ARG SOPS_VERSION=3.13.1
ARG AGE_VERSION=1.3.1
ARG YQ_VERSION=4.53.3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        openssh-client \
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

# Pre-install the tools used by `mise run plan-dns` (cloudflare SOPS flow) so CI
# jobs never fetch them at runtime. Versions must match mise.toml.
RUN mise install \
        "sops@${SOPS_VERSION}" \
        "age@${AGE_VERSION}" \
        "yq@${YQ_VERSION}" && \
    mise reshim

HEALTHCHECK NONE
