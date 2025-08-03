ARG GITHUB_RUNNER_VERSION="2.327.1"
FROM myoung34/github-runner:${GITHUB_RUNNER_VERSION}

# Switch to root user to install packages
USER root

# Install uv, nodejs, and other essentials
RUN apt-get update && \
	apt-get install -y curl && \
	curl -LsSf https://astral.sh/uv/install.sh | sh && \
	curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
	apt-get install -y nodejs && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch back to the runner user
USER runner
