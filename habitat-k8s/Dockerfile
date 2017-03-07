FROM debian:jessie

ENV EDITOR vim

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN useradd -ms /bin/bash demo
RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends \
      apt-utils \
      apt-transport-https \
      build-essential \
      curl \
      ca-certificates \
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
    rm -rf /var/lib/apt/lists/* && \
    wget -q https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

USER demo
WORKDIR /home/demo

RUN pip install --user azure-cli && \
    wget -q "https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux" -O hab.tar.gz && \
    tar -xvzf hab.tar.gz && \
    mkdir /home/demo/bin && \
    tar -xvzf hab.tar.gz -C $HOME/bin --strip-components=1 && \
    echo "PATH=$PATH:$HOME/bin:$HOME/.local/bin" >> $HOME/.bashrc && \
    echo -e "\
    _python_argcomplete() {\n\
        local IFS='\v'\n\
        COMPREPLY=( \$(IFS=\"\$IFS\"                   COMP_LINE=\"\$COMP_LINE\"                   COMP_POINT=\"\$COMP_POINT\"                   _ARGCOMPLETE_COMP_WORDBREAKS=\"\$COMP_WORDBREAKS\"                   _ARGCOMPLETE=1                   \"\$1\" 8>&1 9>&2 1>/dev/null 2>/dev/null) )\n\
        if [[ \$? != 0 ]]; then\n\
            unset COMPREPLY\n\
        fi\n\
    }\n\
    complete -o nospace -F _python_argcomplete \"az\"\n\
    " >> ~/.bashrc && \
    rm -rf $HOME/hab*

COPY docker_scripts $HOME


