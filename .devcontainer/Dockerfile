# Use Ubuntu 26.04 as the base image
FROM ubuntu:26.04

ARG DockerUSER=deww
ARG DockerUID=1000
ARG DockerGID=1000


ENV DEBIAN_FRONTEND=noninteractive
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}"
ENV DockerUSER=${DockerUSER}
ENV DockerUID=${DockerUID}
ENV DockerGID=${DockerGID}

# Copy apt proxy configuration
# COPY apt/proxy.conf /etc/apt/apt.conf.d/01proxy

# Update and install required packages
RUN apt-get update && apt-get install -y \
  curl \
  apt-transport-https \
  ca-certificates \
  lsb-release \
  gnupg \
  git \
  sudo \
  bash-completion \
  build-essential \
  vim \
  jq \
  iproute2 \
  netcat-traditional \
  dnsutils

# Install Docker CLI, Buildx and Compose plugin (docker-in-docker via mounted host socket)
RUN install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
  && chmod a+r /etc/apt/keyrings/docker.asc \
  && DOCKER_CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")" \
  && if ! curl -fsSL "https://download.docker.com/linux/ubuntu/dists/${DOCKER_CODENAME}/Release" > /dev/null 2>&1; then DOCKER_CODENAME=noble; fi \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${DOCKER_CODENAME} stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin


# Configure apt proxy if HTTP_PROXY is set
RUN if [ -n "${HTTP_PROXY}" ]; then \
        echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" > /etc/apt/apt.conf.d/proxy.conf && \
        echo "Acquire::https::Proxy \"${HTTPS_PROXY}\";" >> /etc/apt/apt.conf.d/proxy.conf; \
    fi

USER root

ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Create non-root user
RUN if getent passwd $DockerUID > /dev/null; then userdel -rf $(getent passwd $DockerUID | cut -d ':' -f 1); fi \
  && groupadd --force --gid $DockerGID $DockerUSER \
  && useradd --no-log-init --uid $DockerUID --gid $DockerGID -m $DockerUSER \
  && mkdir -p /etc/sudoers.d/ \
  && echo $DockerUSER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DockerUSER \
  && chmod 0440 /etc/sudoers.d/$DockerUSER \
  && groupadd --force docker \
  && usermod -aG docker $DockerUSER

USER $DockerUSER

# Install Homebrew
RUN echo "Installing Homebrew..." && \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
  echo 'eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"' >> \
  /home/${DockerUSER}/.bashrc


RUN brew install starship lazygit fzf fd ripgrep tmux btop eza neovim zsh gh python rust commitizen uv


RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
  git clone https://github.com/zsh-users/zsh-autosuggestions /home/${DockerUSER}/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
  git clone https://github.com/lukechilds/zsh-nvm /home/${DockerUSER}/.oh-my-zsh/custom/plugins/zsh-nvm && \
  echo 'eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"' >> /home/${DockerUSER}/.zshrc


# Install NVM, Node.js LTS, and update .zshrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
  export NVM_DIR="$HOME/.nvm" && \
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
  nvm install --lts

CMD [ "zsh" ]
