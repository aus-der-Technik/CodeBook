# ----------------------------------------------------------------------------------------
# DOWNLOADER
# ----------------------------------------------------------------------------------------
ARG BASEIMAGE=ubuntu:24.04
FROM ${BASEIMAGE} AS downloader

# Install OS updates and, if needed
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get update && apt-get install -y apt-utils \
    apt-transport-https \
    software-properties-common \
    -y

RUN apt install -y \
    curl wget

WORKDIR /downloads

# kubectl
RUN SYSARCH=$(arch); \
    if [ "$SYSARCH" = "aarch64" ]; then SYSARCH=arm64; fi; \
    if [ "$SYSARCH" = "x86_64" ]; then SYSARCH=amd64; fi; \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${SYSARCH}/kubectl"; \
    chmod 755 /downloads/kubectl

# Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3; \
    chmod 700 /downloads/get_helm.sh;

# Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz

# Swiftly
RUN curl -o swiftly.tar.gz -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz

# ----------------------------------------------------------------------------------------
# BUILD STAGE
# ----------------------------------------------------------------------------------------
ARG BASEIMAGE=ubuntu:24.04
FROM ${BASEIMAGE}
LABEL maintainer="aus der Technik"
LABEL Description="CodeBook"

# Install OS updates and, if needed
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

RUN apt-get update && apt-get install -y apt-utils \
    apt-transport-https \
    software-properties-common \
    -y

RUN apt update \
    && apt dist-upgrade -y
RUN apt install -y \
    libz-dev \
    curl libcurl4-openssl-dev wget \
    gnupg openssh-client \
    git jq unzip \
    libjavascriptcoregtk-4.1-dev \
    python3.12 libpython3.12 python3-pip python3-pip-whl \
    binutils locales locales-all \
    glibc-tools gcc \
    cmake \
    golang \
    libsodium23 pkg-config \
    lldb-15 rust-all \
    openjdk-8-jdk \
    lua-any lua-argparse lua-check lua-cjson lua-doc lua-event lua-filesystem lua-http lua-json lua-posix lua-socket lua-system lua5.4 luadoc luajit \
    tzdata \
    kubecolor kubectx \
    php composer

# kubectl
COPY --from=downloader /downloads/kubectl /usr/local/bin/

# helm
COPY --from=downloader /downloads/get_helm.sh /tmp/get_helm.sh
RUN  /tmp/get_helm.sh

# fix LLDB
RUN apt install python3-lldb-14 -y; \
    ln -s /usr/lib/llvm-14/lib/python3.10/dist-packages/lldb/* /usr/lib/python3/dist-packages/lldb/

# setup tools
RUN pip install setuptools --break-system-packages
    
# Setting up project dir
# ----------------------------------------------------------------------------------------
RUN mkdir /project && chmod 777 /project
COPY ./Sources/entrypoint.sh /

# Install Python 
# ----------------------------------------------------------------------------------------
RUN ln -s /usr/bin/python3 /usr/bin/python 

# Install Spark
# ----------------------------------------------------------------------------------------
WORKDIR /opt/spark
COPY --from=downloader /downloads/spark-3.5.5-bin-hadoop3.tgz /opt/spark/spark-3.5.5-bin-hadoop3.tgz
RUN tar -xvzf spark-3.5.5-bin-hadoop3.tgz; \
    rm spark-3.5.5-bin-hadoop3.tgz
ENV SPARK_HOME=/opt/spark/spark-3.5.5-bin-hadoop3
RUN echo 'SPARK_HOME=/opt/spark/spark-3.5.5-bin-hadoop3' >> /root/.bashrc
RUN echo 'PATH="$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH"' >> /root/.bashrc 
RUN pip install findspark boto3 --break-system-packages

# Install Swift
# ----------------------------------------------------------------------------------------
WORKDIR /opt/swiftly
COPY --from=downloader /downloads/swiftly.tar.gz /opt/swiftly/swiftly.tar.gz
RUN tar zxf swiftly.tar.gz && \
    ./swiftly init --quiet-shell-followup -y && \
    . ~/.local/share/swiftly/env.sh && \
    hash -r \
RUN echo 'source /root/.local/share/swiftly/env.sh' >> /root/.bashrc
RUN /root/.local/share/swiftly/bin/swift --version

# Install NodeJS
# ----------------------------------------------------------------------------------------
WORKDIR /build
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs


# Install Code-Server
# ----------------------------------------------------------------------------------------
RUN curl -fsSL https://code-server.dev/install.sh | sh
ADD Sources/*.vsix /extensions/install/
RUN chmod -R 777 /extensions

# Install public extensions
RUN for ext in vadimcn.vscode-lldb zaaack.markdown-editor ms-toolsai.jupyter ms-python.python stateful.runme rust-lang.rust genuitecllc.codetogether typefox.open-collaboration-tools; do \
  code-server --disable-telemetry --extensions-dir /extensions --install-extension ${ext}; \
  done;

# Install user extensions
RUN for ext in $(find /extensions/install/ -name "*.vsix"); do \
  code-server --disable-telemetry --extensions-dir /extensions --install-extension ${ext}; \
  done;

RUN rm -rf /extensions/install/*

# Install Kernels
# ----------------------------------------------------------------------------------------
# https://github.com/jupyter/jupyter/wiki/Jupyter-kernels
RUN pip install ipywidgets --break-system-packages
RUN pip install bash_kernel --break-system-packages; python3 -m bash_kernel.install
RUN npm install -g tslab --break-system-packages; tslab install;

RUN apt install -y libzmq3-dev python3-aiozmq # need to install it late, because of some python dependencies
RUN cpan -T Alien::ZMQ::latest; cpan -T Devel::IPerl; iperl kernel;

RUN pip install jupyter-c-kernel --break-system-packages; install_c_kernel;
RUN pip install ilua --break-system-packages;
RUN pip install dockerfile-kernel --break-system-packages; python3 -m dockerfile_kernel.install

ADD Sources/kernel /extensions/kernel
RUN pip install /extensions/kernel/echo_kernel --break-system-packages
RUN pip install /extensions/kernel/swift_kernel --break-system-packages

RUN echo 'PATH="$PATH:/root/.cargo/bin"' >> /root/.bashrc
#RUN cargo install --locked evcxr_jupyter; /root/.cargo/bin/evcxr_jupyter --install;
    #cp -r /root/.local/share/jupyter/kernels/rust /extensions/kernel/rust

# Setting the startp
# ----------------------------------------------------------------------------------------
WORKDIR /project
COPY Sources/config.yaml /root/.config/code-server/config.yaml
EXPOSE 31546
ENTRYPOINT ["/entrypoint.sh"]
