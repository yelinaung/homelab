FROM myoung34/github-runner:ubuntu-jammy

# Install uv, nodejs, terraform, tflint, and other essentials
ARG TERRAFORM_VERSION=1.14.5
ARG TFLINT_VERSION=0.61.0
ARG GITLEAKS_VERSION=8.30.0

# Ensure pipelines fail if any command in the chain fails.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && \
	apt-get install --no-install-recommends -y curl unzip gnupg && \
	curl -LsSf https://astral.sh/uv/install.sh | sh && \
	curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
	apt-get install --no-install-recommends -y nodejs && \
	curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
	unzip /tmp/terraform.zip -d /usr/local/bin && rm /tmp/terraform.zip && \
	curl -fsSL https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -o /tmp/tflint.zip && \
	unzip /tmp/tflint.zip -d /usr/local/bin && rm /tmp/tflint.zip && \
	pip install --no-cache-dir semgrep==1.152.0 && \
	curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
		| tar -xz -C /usr/local/bin gitleaks && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

HEALTHCHECK NONE
