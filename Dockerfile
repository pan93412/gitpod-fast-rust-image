## Build mold
FROM gitpod/workspace-c:latest AS mold-stage
USER gitpod

ENV mold_version=1.10.1
ENV mold_artifact_name=mold-${mold_version}-x86_64-linux
ENV mold_artifact_file=${mold_artifact_name}.tar.gz

# Download prebuilt files.
WORKDIR /tmp/mold
ADD https://github.com/rui314/mold/releases/download/v${mold_version}/${mold_artifact_file} .

# Decompress the tar file and move file contents to /tmp/mold-bin
RUN sudo chown gitpod:gitpod "${mold_artifact_file}" && tar -xzvf "${mold_artifact_file}" && mv "${mold_artifact_name}" /tmp/mold-bin

## Install utilities with cargo install.
FROM gitpod/workspace-rust:latest AS cargo-install-stage
USER gitpod

WORKDIR /tmp/cargo-bin

ADD https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz binstall.tgz

# Prepare cargo-binstall
RUN sudo chown gitpod:gitpod binstall.tgz && tar -xvf binstall.tgz && rm binstall.tgz

# Install sccache, cargo-udeps & cargo-nextest
RUN cargo install --root /tmp/cargo-bin --no-default-features sccache

RUN ./cargo-binstall -y --roots /tmp/cargo-bin \
        cargo-udeps \
        cargo-nextest \
        cargo-chef \
        cargo-diet \
        cargo-sort \
        hyperfine \
        cargo-binstall

## Merge artifacts and build the final image.
FROM gitpod/workspace-full:latest

LABEL org.opencontainers.image.title="The speed-optimized and feature-rich Rust Docker image for Gitpod."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.url="https://github.com/pan93412/gitpod-fast-rust-image"

USER gitpod

# Bind sh to bash
RUN sudo ln -fs /bin/bash /bin/sh

# Install apt-fast, nvim and update images
RUN /bin/bash -c "$(curl -sL https://git.io/vokNn)" && \
    sudo apt update && \
    sudo apt-fast install -y neovim && \
    sudo apt-fast upgrade -y &&  \
    sudo rm -rf /var/lib/apt/lists/*

# Install Rust nightly
RUN rustup self update && \
    rustup install nightly && \
    rustup default nightly

# Copy Cargo configuration to this image,
# and initiate this configuration when starting bash.
COPY ./config/config.toml /home/gitpod/.cargo/config.toml
COPY ./scripts/81-cargo-config /home/gitpod/.bashrc.d/

# Copy the prebuilt mold to /usr/local/
COPY --from=mold-stage /tmp/mold-bin /usr/local/

# Copy the prebuilt sccache & cargo-udeps to ~/.cargo/bin
COPY --from=cargo-install-stage /tmp/cargo-bin /home/gitpod/.cargo/
