# ----------------------------------------------------------------------------------------
# BUILD STAGE
# ----------------------------------------------------------------------------------------
ARG BASEIMAGE=ubuntu:22.04
FROM ${BASEIMAGE}
LABEL maintainer="aus der Technik"
LABEL Description="CodeBook"

# Install OS updates and, if needed
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get update && apt-get install -y apt-utils apt-transport-https
RUN apt update \
    && apt dist-upgrade -y
RUN apt install -y \
    libz-dev \
    curl libcurl4-openssl-dev wget \
    gnupg openssh-client \
    git jq unzip \
    libjavascriptcoregtk-4.0-dev \
    python3.10 libpython3.10 python3-pip \
    binutils locales locales-all \
    glibc-tools gcc \
    cmake \
    golang \
    libzmq3-dev libsodium23 pkg-config python3-aiozmq \
    lldb-15 rust-all \
    openjdk-8-jdk \
    lua-any lua-argparse lua-check lua-cjson lua-doc lua-event lua-filesystem lua-http lua-json lua-posix lua-socket lua-system lua5.4 luadoc luajit

# rust-lldb

# fix LLDB
RUN apt install python3-lldb-14 -y; \
    ln -s /usr/lib/llvm-14/lib/python3.10/dist-packages/lldb/* /usr/lib/python3/dist-packages/lldb/

# setup tools
RUN pip install --upgrade pip \
    && pip install --upgrade wheel \
    && pip install setuptools
    
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
RUN wget https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz; \
    tar -xvzf spark-3.5.1-bin-hadoop3.tgz; \
    rm spark-3.5.1-bin-hadoop3.tgz
ENV SPARK_HOME=/opt/spark/spark-3.5.2-bin-hadoop3
RUN echo 'SPARK_HOME=/opt/spark/spark-3.5.2-bin-hadoop3' >> /root/.bashrc
RUN echo 'PATH="$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH"' >> /root/.bashrc 
RUN pip install findspark


# Install Swift
# ----------------------------------------------------------------------------------------
WORKDIR /build
RUN \
  if [ "$(arch)" = "aarch64" ]; then \
    ADD_ARCH="-$(arch)"; \
  fi \
  && wget https://download.swift.org/swift-5.10.1-release/ubuntu2204${ADD_ARCH}/swift-5.10.1-RELEASE/swift-5.10.1-RELEASE-ubuntu22.04${ADD_ARCH}.tar.gz; \
  tar -xvzf swift-5.10.1-RELEASE-ubuntu22.04${ADD_ARCH}.tar.gz; \
  cd swift-5.10.1-RELEASE-ubuntu22.04${ADD_ARCH}; \
  cp -r -T ./usr/. /usr; \
  cd /; rm -rf /build/*;

# Install NodeJS
# ----------------------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs


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
RUN pip install ipywidgets
RUN pip install bash_kernel; python3 -m bash_kernel.install
RUN npm install -g tslab; tslab install;
RUN cpan -T Alien::ZMQ::latest; cpan -T Devel::IPerl; iperl kernel;
RUN pip install jupyter-c-kernel; install_c_kernel;
RUN pip install ilua;

ADD Sources/kernel /extensions/kernel
RUN pip install /extensions/kernel/echo_kernel
RUN pip install /extensions/kernel/swift_kernel

RUN echo 'PATH="$PATH:/root/.cargo/bin"' >> /root/.bashrc
#RUN cargo install evcxr_jupyter; /root/.cargo/bin/evcxr_jupyter --install;
    #cp -r /root/.local/share/jupyter/kernels/rust /extensions/kernel/rust

# Setting the startp
# ----------------------------------------------------------------------------------------
WORKDIR /project
COPY Sources/config.yaml /root/.config/code-server/config.yaml
EXPOSE 31546
ENTRYPOINT ["/entrypoint.sh"]
