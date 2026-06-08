# MUST BE BUILD FROM ROOT OF THE PROJECT WITH: `docker build -t <name>:<tag> -f docker/Dockerfile .`

FROM ghcr.io/astral-sh/uv:python3.10-bookworm

# openslide and ssh dependencies   
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libopenslide0 \
        openssh-server && \
    rm -rf /var/lib/apt/lists/*

# give uv access to the system python and its site-packages
ENV UV_SYSTEM_PYTHON=1

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

# download the models to the location they're expected
RUN cd ./01_WSI_inference_OPENSLIDE_QC/models && \
    curl -L -o ./td/Tissue_Detection_MPP10.pth https://zenodo.org/records/14507273/files/Tissue_Detection_MPP10.pth?download=1 && \
    curl -L -o ./qc/GrandQC_MPP1.pth https://zenodo.org/records/14041538/files/GrandQC_MPP1.pth?download=1 && \
    curl -L -o ./qc/GrandQC_MPP15.pth https://zenodo.org/records/14041538/files/GrandQC_MPP15.pth?download=1 && \
    curl -L -o ./qc/GrandQC_MPP2.pth https://zenodo.org/records/14041538/files/GrandQC_MPP2.pth?download=1 

# not done for the 02_WSI_inference_OPENSLIDE_QC since it's only needed for ome.tiff 

# make sure we are in the project root for the next steps
RUN cd /grandqc

# entry point is opening a bash shell, so that the user can run the commands they want in the container
ENTRYPOINT ["/bin/bash"]