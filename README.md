# OpenClaw Container Image

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-node%3A22--slim-blue)](https://hub.docker.com/_/node)

A Docker image for running [OpenClaw](https://www.npmjs.com/package/openclaw) AI agent pods on Kubernetes.

## What's Included

- **Base**: `node:22-slim` (Debian)
- **OpenClaw**: Latest from npm (`openclaw@latest`) with `matrix-bot-sdk`
- **Tools**: `jq`, `git`, `curl`, `openssh-client`, `gnupg`, `python3`, `gh` (GitHub CLI)

## Build

```bash
docker build -t openclaw:latest .
```

## Push to Registry

```bash
# Tag for your registry
docker tag openclaw:latest your-registry.example.com/library/openclaw:latest

# Push
docker push your-registry.example.com/library/openclaw:latest
```

## Usage with KubeClaw

This image is designed to be used with the [KubeClaw](https://github.com/ZacxDev/kubeclaw) Helm chart for deploying OpenClaw agent devpods on Kubernetes.

```yaml
# In your KubeClaw HelmRelease values:
image:
  repository: your-registry.example.com/library/openclaw
  tag: latest
```

## Building with Kaniko (In-Cluster)

For building directly on a Kubernetes cluster without Docker:

```bash
# Create a ConfigMap with the Dockerfile
kubectl create configmap openclaw-dockerfile --from-file=Dockerfile

# Run Kaniko build job
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: build-openclaw
spec:
  template:
    spec:
      containers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:latest
        args:
        - --dockerfile=/workspace/Dockerfile
        - --context=/workspace
        - --destination=your-registry.example.com/library/openclaw:latest
        volumeMounts:
        - name: dockerfile
          mountPath: /workspace
      restartPolicy: Never
      volumes:
      - name: dockerfile
        configMap:
          name: openclaw-dockerfile
EOF
```

## License

[MIT](LICENSE)
