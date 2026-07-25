FROM node:22-slim

RUN apt-get update && apt-get install -y \
    jq git ca-certificates curl openssh-client gnupg python3 \
    tini rclone poppler-utils unzip \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# renovate: datasource=npm depName=openclaw
ARG OPENCLAW_VERSION=2026.6.1
# --legacy-peer-deps: node:22-slim ships npm 10.9.8, whose arborist crashes with
# "Cannot read properties of null (reading 'edgesOut')" in #loadPeerSet when adding
# a package inside openclaw's already-populated global node_modules. matrix-bot-sdk
# declares no peerDependencies, so skipping peer resolution yields an identical tree
# while avoiding the buggy code path. Keeps matrix-bot-sdk resolvable by openclaw at runtime.
RUN npm install -g openclaw@${OPENCLAW_VERSION} \
    && cd /usr/local/lib/node_modules/openclaw && npm install --legacy-peer-deps matrix-bot-sdk
