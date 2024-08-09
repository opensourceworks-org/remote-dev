FROM --platform=x86_64 debian:latest

ARG USERNAME=remotedev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt update -y && apt upgrade -y && \
    apt install -y make wget curl ssh neovim build-essential cmake libffi-dev \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libffi-dev libsqlite3-dev libgdbm-dev libncursesw5-dev liblzma-dev \
    python3-dev python3-pip python3-venv 

RUN apt install -y sudo openssh-server && apt clean

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
     -p "$(openssl passwd -1 remotedev)" \
     -s /usr/bin/bash \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME 

RUN mkdir /var/run/sshd

CMD ["/usr/sbin/sshd", "-D"]