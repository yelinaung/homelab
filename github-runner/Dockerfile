FROM myoung34/github-runner:ubuntu-jammy

# nosemgrep: dockerfile.security.last-user-is-root.last-user-is-root
# Base image entrypoint requires root to register the runner, then drops privileges internally
USER root

# Install uv, nodejs, and other essentials
RUN apt-get update && \
	apt-get install --no-install-recommends -y curl && \
	curl -LsSf https://astral.sh/uv/install.sh | sh && \
	curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
	apt-get install --no-install-recommends -y nodejs && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

HEALTHCHECK NONE
