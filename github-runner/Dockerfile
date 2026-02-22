ARG GITHUB_RUNNER_VERSION="2.331.0"
FROM myoung34/github-runner:${GITHUB_RUNNER_VERSION}@sha256:388d7e9e25a57ee810c5a4ad167f998dbc518a4fc28061743d3036858cdc58de

# Switch to root user to install packages
USER root

# Install uv, nodejs, and other essentials
RUN apt-get update && \
	apt-get install --no-install-recommends -y curl && \
	curl -LsSf https://astral.sh/uv/install.sh | sh && \
	curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
	apt-get install --no-install-recommends -y nodejs && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

HEALTHCHECK NONE
# Switch back to the runner user
USER runner
