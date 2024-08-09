FROM --platform=linux/amd64 debian:latest

ARG USERNAME=remotedev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt update -y && apt upgrade -y && \
    apt install -y make wget curl ssh neovim build-essential cmake libffi-dev \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libffi-dev libsqlite3-dev libgdbm-dev libncursesw5-dev liblzma-dev \
    python3-dev python3-pip python3-venv 

RUN apt install -y sudo openssh-server && apt clean && mkdir /var/run/sshd

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
     -p "$(openssl passwd -1 remotedev)" \
     -s /usr/bin/bash \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME 


# Install Golang
RUN wget https://go.dev/dl/go1.22.6.linux-amd64.tar.gz && \
    mkdir /usr/local/go1.22.6.linux-amd64 &&\
    tar -C /usr/local/go1.22.6.linux-amd64 -xzf go1.22.6.linux-amd64.tar.gz && \
    ln -s /usr/local/go1.22.6.linux-amd64/go/bin/go /usr/local/bin/go &&\
    rm go1.22.6.linux-amd64.tar.gz

# Set up Go environment variables
RUN echo "export PATH=$PATH:/usr/local/go/bin" >> /home/remotedev/.bashrc &&\
    echo "export GOPATH=$HOME/go" >> /home/remotedev/.bashrc &&\
    echo "export PATH=$PATH:$GOPATH/bin" >> /home/remotedev/.bashrc

# Install Zig
RUN wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz && \
    tar -C /usr/local -xf zig-linux-x86_64-0.13.0.tar.xz && \
    rm zig-linux-x86_64-0.13.0.tar.xz && \
    ln -s /usr/local/zig-linux-x86_64-0.13.0/zig /usr/local/bin/zig

USER remotedev

# Install Rust using rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN echo "PATH=/home/remotedev/.cargo/bin:$PATH" >> /home/remotedev/.bashrc

USER root
CMD ["/usr/sbin/sshd", "-D"]