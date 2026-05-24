# How to build docker images

```bash
docker buildx build -t devpod-template:alpine -f Dockerfile-alpine .
```

```bash
devpod up --devcontainer-path .devcontainer/devcontainer.json --ide vscode --dotfiles https://github.com/dewwripper/dotfiles --dotfiles-script .setup-no-install.sh .
```