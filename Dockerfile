FROM nexus.anotherbrain.lan/base/ubuntu20.04:2.0-python3.8

ENV REQUESTS_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt
ENV POETRY_HOME /etc/poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} python3 - --version 1.3.2
# Make poetry available in PATH
ENV PATH "/etc/poetry/bin:$PATH"


# For VsCode
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
ARG USERNAME=bhousin
ARG USER_UID=3029
ARG USER_GID=2012
# Create the user
# Also, install docker, and some tools, nano and openssh-client are required for git usage
RUN groupadd --gid $USER_GID $USERNAME \
        && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
        && apt-get update \
        && apt-get install --no-install-recommends -y \
        git \
        bash-completion \
        sudo \
        nano \
        openssh-client \
        && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
        && chmod 0440 /etc/sudoers.d/$USERNAME \
        && apt-get autoremove -y\
        && apt-get clean \
        && rm -rf /var/lib/apt-get/lists/*

USER ${USERNAME}
WORKDIR /test_proj

ENV SHELL /bin/bash