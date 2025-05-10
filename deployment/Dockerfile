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
    libzmq3-dev libsodium23 pkg-config python3-aiozmq \
    lldb-15 rust-all \
    openjdk-8-jdk \
    lua-any lua-argparse lua-check lua-cjson lua-doc lua-event lua-filesystem lua-http lua-json lua-posix lua-socket lua-system lua5.4 luadoc luajit \
    tzdata \
    kubecolor \
    php composer

# kube
RUN SYSARCH=$(arch); if [[ ${SYSARCH} == "aarch64" ]]; then SYSARCH=arm64; fi; \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${SYSARCH}/kubectl"; \
    chmod 755 kubectl; mv kubectl /usr/local/bin/;

# helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list; \
    apt-get update; apt-get install helm -y;

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
RUN wget https://archive.apache.org/dist/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz; \
    tar -xvzf spark-3.5.5-bin-hadoop3.tgz; \
    rm spark-3.5.5-bin-hadoop3.tgz
ENV SPARK_HOME=/opt/spark/spark-3.5.5-bin-hadoop3
RUN echo 'SPARK_HOME=/opt/spark/spark-3.5.5-bin-hadoop3' >> /root/.bashrc
RUN echo 'PATH="$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH"' >> /root/.bashrc 
RUN pip install findspark --break-system-packages


# Install Swift
# ----------------------------------------------------------------------------------------
WORKDIR /opt/swiftly
RUN curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
    tar zxf swiftly-$(uname -m).tar.gz && \
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
RUN for ext in vadimcn.vscode-lldb zaaack.markdown-editor ms-toolsai.jupyter ms-python.python stateful.runme rust-lang.rust; do \
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
RUN cpan -T Alien::ZMQ::latest; cpan -T Devel::IPerl; iperl kernel;
RUN pip install jupyter-c-kernel --break-system-packages; install_c_kernel;
RUN pip install ilua --break-system-packages;
RUN pip install dockerfile-kernel --break-system-packages; python3 -m dockerfile_kernel.install

ADD Sources/kernel /extensions/kernel
RUN pip install /extensions/kernel/echo_kernel --break-system-packages
RUN pip install /extensions/kernel/swift_kernel --break-system-packages

RUN echo 'PATH="$PATH:/root/.cargo/bin"' >> /root/.bashrc
#RUN cargo install evcxr_jupyter; /root/.cargo/bin/evcxr_jupyter --install;
    #cp -r /root/.local/share/jupyter/kernels/rust /extensions/kernel/rust

# Setting the startp
# ----------------------------------------------------------------------------------------
WORKDIR /project
COPY Sources/config.yaml /root/.config/code-server/config.yaml
EXPOSE 31546
ENTRYPOINT ["/entrypoint.sh"]
