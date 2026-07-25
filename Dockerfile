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
# "Cannot read properties of null (reading 'edgesOut')" in #loadPeerSet when adding a
# package inside openclaw's already-populated global node_modules. The flag skips peer
# resolution tree-wide, avoiding the buggy code path. It's a no-op on the resulting tree
# here because the only peer in the added subtree (request-promise[-core] → request ^2.34)
# is ALREADY satisfied by matrix-bot-sdk's own request@^2.88.2 — verified byte-identical to a
# plain install on a fixed npm (11.x/12.x). Keeps matrix-bot-sdk resolvable by openclaw.
# matrix-bot-sdk is PINNED (openclaw constrains ^0.8.0) so a future 0.9.x can't silently float.
RUN npm install -g openclaw@${OPENCLAW_VERSION} \
    && cd /usr/local/lib/node_modules/openclaw && npm install --legacy-peer-deps matrix-bot-sdk@0.8.0
