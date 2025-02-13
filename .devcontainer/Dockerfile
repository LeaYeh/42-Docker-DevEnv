# Builder stage
FROM ubuntu:22.04 AS builder

# Install build dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    gcc \
    git \
    make \
    wget \
    # Minilibx dependencies
    libbsd-dev \
    libx11-dev \
    libxext-dev \
    xorg \
    zlib1g-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Valgrind 3.18.1
RUN wget https://sourceware.org/pub/valgrind/valgrind-3.18.1.tar.bz2 \
    && tar -xjf valgrind-3.18.1.tar.bz2 \
    && cd valgrind-3.18.1 \
    && ./configure \
    && make -j \
    && make -j install DESTDIR=/install \
    && cd .. \
    && rm -rf valgrind-3.18.1*

# Make 4.3
RUN wget http://ftp.gnu.org/gnu/make/make-4.3.tar.gz \
    && tar -xvzf make-4.3.tar.gz \
    && cd make-4.3 \
    && ./configure \
    && make -j \
    && make -j install DESTDIR=/install \
    && cd .. \
    && rm -rf make-4.3*

# Readline 8.1
RUN wget https://ftp.gnu.org/gnu/readline/readline-8.1.tar.gz \
    && tar -xzvf readline-8.1.tar.gz \
    && cd readline-8.1 \
    && ./configure --enable-shared \
    && make -j \
    && make -j install DESTDIR=/install \
    && cd .. \
    && rm -rf readline-8.1*

# Install MLX library
RUN git clone https://github.com/42Paris/minilibx-linux.git \
    && cd minilibx-linux \
    && make -j \
    && mkdir -p /install/usr/local/lib \
    && mkdir -p /install/usr/local/include \
    && mkdir -p /install/usr/local/share/man/man3 \
    && cp libmlx.a /install/usr/local/lib \
    && cp mlx.h /install/usr/local/include \
    && gzip -9 man/man3/mlx*.3 \
    && cp man/man3/mlx*.3.gz /install/usr/local/share/man/man3 \
    && cd .. \
    && rm -rf minilibx-linux


# Final stage
FROM ubuntu:22.04 AS final

# Comment out man and doc exclusions from Minimal Ubuntu base image to keep documentation
RUN sed -i \
    -e '/path-exclude=\/usr\/share\/man/s/^/#/' \
    -e '/path-exclude=\/usr\/share\/doc/s/^/#/' \
    /etc/dpkg/dpkg.cfg.d/excludes || true

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y \
    # Man pages
    man-db \
    manpages \
    manpages-dev \
    manpages-posix \
    manpages-posix-dev \
    && /usr/bin/mandb \
    && mv /usr/bin/man.REAL /usr/bin/man \
    && apt-get install -y \
    # System utilities
    curl \
    git \
    gnupg \
    locales \
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
    libx11-dev \
    libxext-dev \
    pkg-config \
    xorg \
    zlib1g-dev \
    # User utilities
    fish \
    #TODO Maybe don't install git-lfs if it's also not on campus
    git-lfs \
    python3 \
    python3-pip \
    python3-venv \
    ncdu \
    rsync \
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
ARG USERNAME=devcontainer
ARG UID=1000
ARG GID=1000

# Create the user
RUN groupadd --gid $GID $USERNAME \
    && useradd --uid $UID --gid $GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the default home directory
ARG HOME=/home/$USERNAME

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Create a virtual environment and activate it
RUN python3 -m venv /opt/venv \
    && chown -R $USERNAME:$USERNAME /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install francinette
RUN bash -c "$(curl -fsSL https://raw.github.com/xicodomingues/francinette/master/bin/install.sh)"

# Change ownership of installed tools to the new user
RUN chown -R $USERNAME:$USERNAME $HOME

# Change zsh history to append mode to avoid error messages
RUN echo "unsetopt HIST_SAVE_BY_COPY" >> /etc/zsh/zshrc

# Copy entrypoint script from build context
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the default user
USER $USERNAME
ENV USER=$USERNAME

# Set useful environment variables
ENV SHELL=/bin/zsh
ENV LANG=C.UTF-8

# Set the working directory in the container
ARG WORKSPACE_FOLDER=/app
WORKDIR "/${WORKSPACE_FOLDER#/}"

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ] #TODO Manual docker run will now fail bc this script will not exist
#! This also fails atm?? `docker-compose up --build -d 42-docker-devenv && docker exec -it $(docker-compose ps -q 42-docker-devenv) /bin/zsh`
CMD [ "/bin/zsh" ]
