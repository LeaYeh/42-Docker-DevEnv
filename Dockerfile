# Start from the latest Ubuntu version
FROM ubuntu:latest

# Update the system and install utils
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    cmake \
    meson \
    valgrind \
    build-essential \
    binutils \
    clang \
    zsh \
    git \
    wget \
    curl \
    python3 python3-venv python3-pip \
    libreadline-dev \
    libreadline8 \
    xorg libxext-dev zlib1g-dev libbsd-dev \
    libcmocka-dev \
    pkg-config

# Download and install the latest version of make
RUN wget http://ftp.gnu.org/gnu/make/make-4.3.tar.gz && \
    tar -xvzf make-4.3.tar.gz && \
    cd make-4.3 && \
    ./configure && \
    make && \
    sudo make install

# Create a virtual environment and activate it
RUN python3 -m venv /opt/venv
RUN chown -R $USER:$USER /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

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

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
RUN echo "source $HOME/.oh-my-zsh/oh-my-zsh.sh" >> $HOME/.zshrc

# Set the working directory in the container to /app
WORKDIR /app

CMD ["/bin/zsh"]
