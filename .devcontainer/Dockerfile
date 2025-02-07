# Builder stage
FROM ubuntu:22.04 AS builder

# Install build dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    gcc \
    git \
    make \
    wget \
    # Minilibx dependencies
    libbsd-dev \
    libxext-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Valgrind 3.18.1
RUN wget https://sourceware.org/pub/valgrind/valgrind-3.18.1.tar.bz2 \
    && tar -xjf valgrind-3.18.1.tar.bz2 \
    && cd valgrind-3.18.1 \
    && ./configure \
    && make \
    && make install DESTDIR=/install \
    && cd .. \
    && rm -rf valgrind-3.18.1*

# Make 4.3
RUN wget http://ftp.gnu.org/gnu/make/make-4.3.tar.gz \
    && tar -xvzf make-4.3.tar.gz \
    && cd make-4.3 \
    && ./configure \
    && make \
    && make install DESTDIR=/install \
    && cd .. \
    && rm -rf make-4.3*

# Readline 8.1
RUN wget https://ftp.gnu.org/gnu/readline/readline-8.1.tar.gz \
    && tar -xzvf readline-8.1.tar.gz \
    && cd readline-8.1 \
    && ./configure --enable-shared \
    && make \
    && make install DESTDIR=/install \
    && cd .. \
    && rm -rf readline-8.1*

# Install MLX library
RUN git clone https://github.com/42Paris/minilibx-linux.git \
    && cd minilibx-linux \
    && make \
    && mkdir -p /install/usr/local/lib \
    && mkdir -p /install/usr/local/include \
    && cp libmlx.a /install/usr/local/lib \
    && cp mlx.h /install/usr/local/include \
    && cd .. \
    && rm -rf minilibx-linux


# Final stage
FROM ubuntu:22.04

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y \
    # System utilities
    curl \
    git \
    gnupg \
    software-properties-common \
    sudo \
    wget \
    zsh \
    # Add LLVM and GCC repositories
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-12 main" \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get install -y \
    # Build tools and compilers
    binutils \
    build-essential \
    clang \
    clang-14 \
    clang-12 \
    cmake \
    gcc-11=11.4.0-1ubuntu1~22.04 \
    g++-11=11.4.0-1ubuntu1~22.04 \
    gcc-10=10.5.0-1ubuntu1~22.04 \
    g++-10=10.5.0-1ubuntu1~22.04 \
    meson \
    # Development tools
    clang-tools \
    clang-tools-12 \
    clangd \
    cppcheck \
    gdb \
    lldb-12 \
    valgrind \
    # Libraries
    libbsd-dev \
    libcmocka-dev \
    libreadline-dev \
    libreadline8 \
    libxext-dev \
    pkg-config \
    xorg \
    zlib1g-dev \
    # User utilities
    python3 \
    python3-pip \
    python3-venv \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Set up compiler aliases
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 100 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang-12 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-12 100

# Copy built artifacts from builder
COPY --from=builder /install /

# Install norminette
RUN python3 -m pip install --upgrade pip setuptools
RUN python3 -m pip install norminette

# Configure default user and workspace paths
# These can be overridden at build time using --build-arg
ARG USER=devcontainer
ARG USER_UID=1000
ARG USER_GID=1000
ARG WORKSPACE_FOLDER=/workspaces
ARG WORKSPACE_NAME=app
ARG HOME=/home/$USER

# Create the user
RUN groupadd --gid $USER_GID $USER \
    && useradd --uid $USER_UID --gid $USER_GID -m $USER \
    && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Create a virtual environment and activate it
RUN python3 -m venv /opt/venv
RUN chown -R $USER:$USER /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install francinette
RUN bash -c "$(curl -fsSL https://raw.github.com/xicodomingues/francinette/master/bin/install.sh)"

# Change ownership of installed tools to the new user
RUN chown -R $USER:$USER $HOME

# Change zsh history to append mode to avoid error messages
RUN echo "unsetopt HIST_SAVE_BY_COPY" >> /etc/zsh/zshrc

# Set the default user for the container
USER $USER
ENV USER=$USER

# Set the working directory in the container
WORKDIR "$WORKSPACE_FOLDER/$WORKSPACE_NAME"

CMD ["/bin/zsh"]
