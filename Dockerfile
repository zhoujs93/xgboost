FROM rapidsai/base:25.04-cuda11.8-py3.11

# 1) Make sure we're running as root
USER root

# 2) Install system packages (openssh-server, curl, tar, etc.)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       openssh-server curl tar && \
    rm -rf /var/lib/apt/lists/*

# 3) Configure SSH keys
RUN mkdir -p /root/.ssh && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHSYar3+KJe6Lc+mWsAIBjYbbaygO/dFaPsjwxmRjqYjCMoPsWGEqCPb4ftRhUUAQ3dH1MGI7ieahJ3dEl2wBVVCNK7Qafr01RqnbTnZI/yGxkPH/uQPCJSStLxFJkDhCTok85RTy+9/qwiJHHv3v2Fi2XCk1Y7fd5iPSKwMD4dybqlpwsgwV3jjlcoBxXsio/LVyciGDvSIz6Vrm+iuwlLzXRd69jWSzt1eQGaF5e2Y1XhS9+cS2DwYjo/BOYG4qTtxR+zkfFGCLg3byiwx5AEVYCAYOhjBJpmvUUcBcvHo9U88sZfgJtbN3+K3PK99BLr1vW4JAJ/A0Fm3++yvYZ putsncalls23' > /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 4) Install JupyterLab & Google Cloud SDK via conda/mamba
RUN mamba install -y -c conda-forge jupyterlab && \
    # (or use your curl/tar/install.sh lines for gcloud)
    mamba clean -afy

# 5) Drop back to the rapids user if you want
# USER rapids

EXPOSE 22 8888

CMD service ssh start && \
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=""
