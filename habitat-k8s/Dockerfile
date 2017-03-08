FROM debian:jessie

ENV EDITOR vim

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
      apt-utils \
      apt-transport-https \
      build-essential \
      curl \
      ca-certificates \
      software-properties-common \
      git \
      lsb-release \
      python-all \
      python-dev \
      rlwrap \
      vim \
      nano \
      bash \
      gcc \
      libffi-dev \
      libssl-dev \
      musl-dev \
      wget \
      openssl \
      openssh-client \
      jq \
      sudo && \
    update-ca-certificates && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) \
       stable" && \
    apt-get update -qq && \
    apt-get install docker-ce -qqy --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl && \
    wget -q "https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux" -O hab.tar.gz && \
    tar -xvzf hab.tar.gz && \
    tar -xvzf hab.tar.gz -C /usr/local/bin/ --strip-components=1 && \
    useradd -ms /bin/bash demo && echo "demo:demo" | chpasswd && adduser demo sudo && \
    echo '%sudo ALL=NOPASSWD: ALL' > /etc/sudoers.d/sudoers-nopassword

USER demo
WORKDIR /home/demo

RUN pip install --user azure-cli && \
    echo "PATH=$PATH:$HOME/.local/bin" >> $HOME/.bashrc && \
    $HOME/.local/bin/az component update --add acr && \
    echo -e "\
    _python_argcomplete() {\n\
        local IFS='\v'\n\
        COMPREPLY=( \$(IFS=\"\$IFS\"                   COMP_LINE=\"\$COMP_LINE\"                   COMP_POINT=\"\$COMP_POINT\"                   _ARGCOMPLETE_COMP_WORDBREAKS=\"\$COMP_WORDBREAKS\"                   _ARGCOMPLETE=1                   \"\$1\" 8>&1 9>&2 1>/dev/null 2>/dev/null) )\n\
        if [[ \$? != 0 ]]; then\n\
            unset COMPREPLY\n\
        fi\n\
    }\n\
    complete -o nospace -F _python_argcomplete \"az\"\n\
    " >> ~/.bashrc

COPY docker_scripts $HOME


