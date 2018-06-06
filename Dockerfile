FROM docker:17.12.0-ce as static-docker-source

FROM debian:jessie
ENV CLOUD_SDK_VERSION 203.0.0

COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
RUN apt-get -qqy update && apt-get install -qqy \
        curl \
        gcc \
        python-dev \
        python-setuptools \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
    && easy_install -U pip && \
    pip install -U crcmod   && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-python=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-go=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-datalab=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-pubsub-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-bigtable-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-cbt=${CLOUD_SDK_VERSION}-0 \
        kubectl && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version && \
    docker --version && kubectl version --client
    
# Install Ruby
RUN cd /tmp && wget -O ruby-install-0.6.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.1.tar.gz && \
    tar -xzvf ruby-install-0.6.1.tar.gz && \
    cd ruby-install-0.6.1 && \
    sudo make install && \
    ruby-install --cleanup ruby 2.4.3 && \
    rm -r /tmp/ruby-install-*

ENV PATH ${HOME}/.rubies/ruby-2.4.3/bin:${PATH}
RUN echo 'gem: --env-shebang --no-rdoc --no-ri' >> ~/.gemrc && gem install bundler

VOLUME ["/root/.config"]
