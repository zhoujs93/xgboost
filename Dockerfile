FROM rapidsai/base:25.04-cuda11.8-py3.11

# Switch to root to install system packages and tools
USER root

# Install SSH, curl, tar, wget and configure root SSH access
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server curl tar wget && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir -p /var/run/sshd /root/.ssh && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHSYar3+KJe6Lc+mWsAIBjYbbaygO/dFaPsjwxmRjqYjCMoPsWGEqCPb4ftRhUUAQ3dH1MGI7ieahJ3dEl2wBVVCNK7Qafr01RqnbTnZI/yGxkPH/uQPCJSStLxFJkDhCTok85RTy+9/qwiJHHv3v2Fi2XCk1Y7fd5iPSKwMD4dybqlpwsgwV3jjlcoBxXsio/LVyciGDvSIz6Vrm+iuwlLzXRd69jWSzt1eQGaF5e2Y1XhS9+cS2DwYjo/BOYG4qTtxR+zkfFGCLg3byiwx5AEVYCAYOhjBJpmvUUcBcvHo9U88sZfgJtbN3+K3PK99BLr1vW4JAJ/A0Fm3++yvYZ putsncalls23' > /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && \
    rm -rf /var/lib/apt/lists/*

# Install JupyterLab via conda
RUN mamba install -y -c conda-forge jupyterlab && \
    mamba clean -afy

# Install Google Cloud CLI manually
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-466.0.0-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-466.0.0-linux-x86_64.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    rm -f google-cloud-cli-466.0.0-linux-x86_64.tar.gz

# Add gcloud/gsutil to PATH
ENV PATH="/google-cloud-sdk/bin:${PATH}"

# Install full Anaconda distribution
RUN wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh && \
    chmod +x Anaconda3-2024.10-1-Linux-x86_64.sh && \
    ./Anaconda3-2024.10-1-Linux-x86_64.sh -b -p /opt/anaconda3 && \
    rm -f Anaconda3-2024.10-1-Linux-x86_64.sh

# Add Anaconda to PATH
ENV PATH="/opt/anaconda3/bin:${PATH}"

# Create Python 3.12 environment in Anaconda
RUN conda create -y -n python312 python=3.12 && \
    conda clean -afy

# Install GPU-enabled XGBoost into the new Python 3.12 environment
RUN conda run -n python312 conda install -y -c rapidsai -c conda-forge rapids-xgboost && \
    conda clean -afy

# Expose SSH and JupyterLab ports
EXPOSE 22 8888

# Start SSH and JupyterLab by default
CMD service ssh start && \
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=""
