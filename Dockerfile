# As this is a derived service from the image classification model
# so we can resuse the original image classification image.

# Options: cpu, gpu, cpu-test, gpu-test
ARG tag=cpu

# Base image, e.g. tensorflow/tensorflow:1.12.0-py3
FROM deephdc/deep-oc-image-classification-tf:${tag}

# Add container's metadata to appear along the models metadata
ENV CONTAINER_MAINTAINER "Lara Lloret Iglesias <lloret@ifca.unican.es>"
ENV CONTAINER_VERSION "0.1"
ENV CONTAINER_DESCRIPTION "DEEP as a Service Container: Plants Classification"

## Download network weights (trained on Plantnet)
#ENV SWIFT_CONTAINER https://cephrgw01.ifca.es:8080/swift/v1/plants-tf/
#ENV MODEL_TAR plants.tar.xz

# Download network weights (trained on iNaturalist)
ENV SWIFT_CONTAINER https://cephrgw01.ifca.es:8080/swift/v1/inaturalist_plants-tf/
ENV MODEL_TAR inaturalist_plants.tar.xz

RUN rm -rf image-classification-tf/models/*

RUN curl --insecure -o ./image-classification-tf/models/${MODEL_TAR} \
    ${SWIFT_CONTAINER}${MODEL_TAR}

RUN cd image-classification-tf/models && \
    tar -xf ${MODEL_TAR} &&\
    rm ${MODEL_TAR}
