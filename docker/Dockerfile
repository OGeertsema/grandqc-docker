# MUST BE BUILD FROM ROOT OF THE PROJECT WITH: `docker build -t <name>:<tag> -f docker/Dockerfile .`
# Op mac build: docker build --platform linux/amd64 -t <name>:<tag> -f docker/Dockerfile .

ARG UBUNTU_VERSION=22.04
ARG CUDA_MAJOR_VERSION=12.1.0
ARG CUDNN_MAJOR_VERSION=8

# making separate stages for downloading the models and for building the final image, 
# to speed up the build process since the models won't be downloaded again if only the code changes, 
# and to avoid having to download the models every time we build the image (e.g. for testing)
FROM nvidia/cuda:${CUDA_MAJOR_VERSION}-cudnn${CUDNN_MAJOR_VERSION}-runtime-ubuntu${UBUNTU_VERSION} AS downloader

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /downloads

RUN mkdir -p td && \
    mkdir -p qc

RUN curl -L -o ./td/Tissue_Detection_MPP10.pth https://zenodo.org/records/14507273/files/Tissue_Detection_MPP10.pth?download=1 && \
    curl -L -o ./qc/GrandQC_MPP1.pth https://zenodo.org/records/14041538/files/GrandQC_MPP1.pth?download=1 && \
    curl -L -o ./qc/GrandQC_MPP15.pth https://zenodo.org/records/14041538/files/GrandQC_MPP15.pth?download=1 && \
    curl -L -o ./qc/GrandQC_MPP2.pth https://zenodo.org/records/14041538/files/GrandQC_MPP2.pth?download=1 
 
FROM nvidia/cuda:${CUDA_MAJOR_VERSION}-cudnn${CUDNN_MAJOR_VERSION}-runtime-ubuntu${UBUNTU_VERSION} AS grandqc-docker
 
ARG PYTHON_VERSION=3.10
 
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# openslide and ssh dependencies   
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        vim \
        gcc \
        git \
        openssh-server \
        libgl1 \
        libgomp1 \
        libjpeg-turbo8 \
        libopenslide-dev \
        libxml2-dev \
        libxslt-dev && \
    rm -rf /var/lib/apt/lists/*

# install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
# give uv access to the system python and its site-packages
ENV UV_SYSTEM_PYTHON=1

# install python
RUN uv python install ${PYTHON_VERSION}

# set the working directory to the project root 
WORKDIR /grandqc

# install the project dependencies 
COPY pyproject.toml ./
COPY uv.lock ./
RUN uv sync --no-dev --frozen

# activate the virtual environment
ENV PATH="/grandqc/.venv/bin:$PATH"

# copy relevant files
COPY 01_WSI_inference_OPENSLIDE_QC ./01_WSI_inference_OPENSLIDE_QC
# 02 only needed for ome.tiff
# COPY 02_WSI_inference_OPENSLIDE_QC ./02_WSI_inference_OPENSLIDE_QC

# make the dirs for the model weights
RUN mkdir -p 01_WSI_inference_OPENSLIDE_QC/models/td && \
    mkdir -p 01_WSI_inference_OPENSLIDE_QC/models/qc

# copy the models to the location they're expected
COPY --from=downloader /downloads/td/Tissue_Detection_MPP10.pth ./01_WSI_inference_OPENSLIDE_QC/models/td/Tissue_Detection_MPP10.pth
COPY --from=downloader /downloads/qc/GrandQC_MPP1.pth ./01_WSI_inference_OPENSLIDE_QC/models/qc/GrandQC_MPP1.pth
COPY --from=downloader /downloads/qc/GrandQC_MPP15.pth ./01_WSI_inference_OPENSLIDE_QC/models/qc/GrandQC_MPP15.pth
COPY --from=downloader /downloads/qc/GrandQC_MPP2.pth ./01_WSI_inference_OPENSLIDE_QC/models/qc/GrandQC_MPP2.pth

# not done for the 02_WSI_inference_OPENSLIDE_QC since it's only needed for ome.tiff 

# make sure we are in the project root for the next steps
RUN cd /grandqc

# entry point is opening a bash shell, so that the user can run the commands they want in the container
ENTRYPOINT ["/bin/bash"]