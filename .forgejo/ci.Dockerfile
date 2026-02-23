# Multi-stage build for CI tooling
FROM python:3.14-slim-bookworm AS base

# Set build-time variables for versions
ARG GO_VERSION=1.25.0
ARG NODE_VERSION=24
ARG TERRAFORM_VERSION=1.10.3
ARG TFLINT_VERSION=0.55.0

# Use pipefail so piped RUN commands fail on upstream command errors.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies in one layer
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ===== GOLANG STAGE =====
FROM base AS golang-installer
ARG GO_VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xzf -

# ===== NODE.JS STAGE =====
FROM base AS nodejs-installer
ARG NODE_VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Use NodeSource binary distribution for cleaner installation
RUN curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}.5.0/node-v${NODE_VERSION}.5.0-linux-x64.tar.xz" | tar -C /opt -xJ \
    && mv "/opt/node-v${NODE_VERSION}.5.0-linux-x64" /opt/nodejs

# ===== TERRAFORM STAGE =====
FROM base AS terraform-installer
ARG TERRAFORM_VERSION
ARG TFLINT_VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=VERSION_CODENAME=).*' /etc/os-release) main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends terraform \
    && rm -rf /var/lib/apt/lists/* \
    # Install tflint
    && curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" -o tflint.zip \
    && unzip tflint.zip -d /usr/local/bin \
    && rm tflint.zip \
    && chmod +x /usr/local/bin/tflint

# ===== PYTHON TOOLS STAGE =====
FROM base AS python-installer
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Install UV first (more efficient than pip for other tools)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Use UV to install Python packages (much faster)
RUN /root/.local/bin/uv pip install --system --no-cache-dir \
    ruff \
    pytest \
    pytest-xdist \
    setuptools

# ===== FINAL STAGE =====
FROM base AS final
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create non-root user for security
RUN useradd -m -u 1000 -s /bin/bash ciuser \
    && usermod -aG sudo ciuser

# Copy installed tools from previous stages
COPY --from=golang-installer /usr/local/go /usr/local/go
COPY --from=nodejs-installer /opt/nodejs /opt/nodejs
COPY --from=terraform-installer /usr/bin/terraform /usr/bin/terraform
COPY --from=terraform-installer /usr/local/bin/tflint /usr/local/bin/tflint
COPY --from=python-installer /root/.local/bin/uv /usr/local/bin/uv
COPY --from=python-installer /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=python-installer /usr/local/bin/ruff /usr/local/bin/ruff
COPY --from=python-installer /usr/local/bin/pytest /usr/local/bin/pytest

# Install Docker CLI (not daemon - for CI use)
# hadolint ignore=DL3008
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli jq \
    && rm -rf /var/lib/apt/lists/*

# Set up environment
ENV PATH="/usr/local/go/bin:/opt/nodejs/bin:${PATH}"
ENV GOPATH="/home/ciuser/go"
ENV GOPROXY="https://proxy.golang.org,direct"
ENV UV_CACHE_DIR="/home/ciuser/.uv-cache"

# Create cache directories with proper permissions
RUN mkdir -p /home/ciuser/.uv-cache /home/ciuser/go \
    && chown -R ciuser:ciuser /home/ciuser

# Verify installations and show versions
RUN python --version \
    && uv --version \
    && go version \
    && node --version \
    && npm --version \
    && terraform version \
    && tflint --version \
    && docker --version \
    && jq --version

# Set working directory
WORKDIR /workspace
RUN chown ciuser:ciuser /workspace

# Basic liveness check for CI image tooling.
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD bash -lc 'python --version >/dev/null && terraform version >/dev/null && node --version >/dev/null' || exit 1

# Switch to non-root user
USER ciuser

# Default command
CMD ["/bin/bash"]
