FROM debian:buster

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt, install base packages, SDKs & tools
RUN apt-get update \
    && apt-get install -y git less procps lsb-release curl wget ca-certificates apt-transport-https gnupg \
    && curl -sL https://packages.microsoft.com/config/debian/10/prod.list -o /etc/apt/sources.list.d/microsoft-prod.list \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ buster main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y azure-cli openjdk-11-jdk dotnet-sdk-3.1

# Golang
WORKDIR /tmp
RUN curl -fsS https://dl.google.com/go/go1.16.8.linux-amd64.tar.gz -o golang.tar.gz \
    && tar -xvf golang.tar.gz \
    && rm -rf /usr/local/go \
    && mv go /usr/local
ENV GO111MODULE=on
ENV CGO_ENABLED=0

# Maven
RUN curl -sSL https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -o maven.tar.gz \
    && tar -xzf maven.tar.gz \
    && mv apache-maven-3.6.3 /opt \
    && rm maven.tar.gz

# Node 12.x
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs

# Docker client
RUN curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.8.tgz -o docker.tgz \
    && tar -zxvf docker.tgz docker/docker \
    && chmod +x docker/docker \
    && mv docker/docker /usr/bin/docker \
    && rm -rf docker \
    && rm docker.tgz

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && groupadd docker || true \
    && usermod -aG docker $USERNAME

# Cleanup apt
RUN apt-get autoremove -y \
    && apt-get clean -y 

# Paths and user set up
RUN echo 'export PATH="$HOME/go/bin:/usr/local/go/bin:/opt/apache-maven-3.6.3/bin:$PATH"' >> /etc/bash.bashrc
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /etc/bash.bashrc
WORKDIR /home/$USERNAME