FROM tensorflow/tensorflow:1.12.0-py3
LABEL maintainer="Lara Lloret Iglesias <lloret@ifca.unican.es>"
LABEL version="0.1"
LABEL description="DEEP as a Service Container: Seeds Classification"

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
        curl \
        git \
		libsm6  \
        libxrender1 \ 
        libxext6 \
        psmisc \
		python3-tk

# We could shrink the dependencies, but this is a demo container, so...
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         build-essential

WORKDIR /srv

# Install the image classifier package
RUN git clone https://github.com/indigo-dc/image-classification-tf && \
    cd image-classification-tf && \
    python -m pip install -e . && \
    cd ..

# Install DEEPaaS
RUN pip install deepaas

# Useful tool to debug extensions loading
RUN python -m pip install entry_point_inspector

# Download network weights
ENV SWIFT_CONTAINER https://cephrgw01.ifca.es:8080/swift/v1/plants-tf/
ENV MODEL_TAR plants.tar.xz

RUN curl -o ./image-classification-tf/models/${MODEL_TAR} \
    ${SWIFT_CONTAINER}${MODEL_TAR}

RUN cd image-classification-tf/models && \
        tar -xf ${MODEL_TAR}

# Install rclone
RUN apt-get install -y wget nano && \
    wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Expose API on port 5000
EXPOSE 5000

CMD deepaas-run --listen-ip 0.0.0.0

