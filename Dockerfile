# Start from the latest Ubuntu version
FROM ubuntu:latest

# Update the system and install utils
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    valgrind \
    build-essential \
    binutils \
    clang-12 \
    git \
    zsh \
    wget \
    curl \
    python3 python3-pip \
    libreadline-dev \
    libreadline8 \
    xorg libxext-dev zlib1g-dev libbsd-dev

# Download and install the latest version of make
RUN wget http://ftp.gnu.org/gnu/make/make-4.3.tar.gz && \
    tar -xvzf make-4.3.tar.gz && \
    cd make-4.3 && \
    ./configure && \
    make && \
    make install

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
RUN echo "source $HOME/.oh-my-zsh/oh-my-zsh.sh" >> $HOME/.zshrc

# Set up the user as a sudoer
ARG USER
RUN sudo adduser --disabled-password --gecos "" $USER
RUN sudo usermod -aG sudo $USER
RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
USER $USER

# Upgrade pip and setuptools and install norminette
RUN python3 -m pip install --upgrade pip setuptools
RUN python3 -m pip install norminette

# Install MLX library
RUN cd $HOME && \
    git clone https://github.com/42Paris/minilibx-linux.git && \
    cd minilibx-linux && \
    make && \
    sudo cp mlx.h /usr/local/include && \
    sudo cp libmlx.a /usr/local/lib

# Install francinette
RUN bash -c "$(curl -fsSL https://raw.github.com/xicodomingues/francinette/master/bin/install.sh)"

# Set the working directory in the container to /app
WORKDIR /app

RUN sudo chmod -R 755 /app
RUN getent group sudo
RUN sudo chown -R $USER:$USER /app
