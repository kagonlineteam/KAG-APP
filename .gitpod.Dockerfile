FROM gitpod/workspace-full
SHELL ["/bin/bash", "-c"]

# Install dart
USER root
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && curl -fsSL https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list \
    && install-packages build-essential dart libkrb5-dev

# Install flutter
USER gitpod
RUN git clone https://github.com/flutter/flutter

RUN flutter/bin/flutter precache
RUN echo 'export PATH="$PATH:/home/gitpod/flutter/bin"' >> /home/gitpod/.bashrc

USER root

# misc deps
RUN apt-get update
RUN apt-get install -y \
  libasound2-dev \
  libgtk-3-dev \
  libnss3-dev \
  fonts-noto \
  fonts-noto-cjk

# For Qt WebEngine on docker
ENV QTWEBENGINE_DISABLE_SANDBOX 1

USER gitpod