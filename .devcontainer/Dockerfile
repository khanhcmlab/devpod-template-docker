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
    jq

USER root

# Create non-root user
RUN if getent passwd $DockerUID > /dev/null; then userdel -rf $(getent passwd $DockerUID | cut -d ':' -f 1); fi \
    && groupadd --force --gid $DockerGID $DockerUSER \
    && useradd --no-log-init --uid $DockerUID --gid $DockerGID -m $DockerUSER \
    && mkdir -p /etc/sudoers.d/ \
    && echo $DockerUSER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DockerUSER \
    && chmod 0440 /etc/sudoers.d/$DockerUSER

USER $DockerUSER

# Install Homebrew
RUN echo "Installing Homebrew..." && \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"' >> \
    /home/${DockerUSER}/.bashrc


RUN brew install starship lazygit fzf fd ripgrep tmux btop eza neovim zsh gh

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Antigravity CLI
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

# Add .cargo/bin and .local/bin to PATH for uv and installed tools
ENV PATH="/home/${DockerUSER}/.cargo/bin:/home/${DockerUSER}/.local/bin:$PATH"


# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/${DockerUSER}/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/lukechilds/zsh-nvm /home/${DockerUSER}/.oh-my-zsh/custom/plugins/zsh-nvm

# Install NVM, Node.js LTS, and update .zshrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    npm install -g @anthropic-ai/claude-code

# Install Free Claude Code Proxy
RUN uv python install 3.14 && \
    uv tool install --force git+https://github.com/Alishahryar1/free-claude-code.git

# Install specify-cli (GitHub Spec Kit)
RUN uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Install OpenCode AI coding agent
RUN curl -fsSL https://opencode.ai/install | bash

EXPOSE 8082

CMD [ "zsh" ]