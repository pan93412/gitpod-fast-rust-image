## Build mold
FROM gitpod/workspace-c:2022-12-15-12-38-23 AS mold-stage
USER gitpod

ENV mold_version=v1.7.1

# Clone mold's repo.
RUN git clone --depth=1 --branch="${mold_version}" https://github.com/rui314/mold.git /tmp/mold
WORKDIR /tmp/mold/build

# Install dependencies.
RUN sudo ../install-build-deps.sh

# Build mold.
RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ ..
RUN cmake --build . -j $(nproc)
RUN sudo cmake --install .

# Install mold to a temporary path.
RUN mkdir -p /tmp/mold-bin && sudo cmake --install . --prefix /tmp/mold-bin


## Install utilities with cargo install.
FROM gitpod/workspace-rust:2022-12-15-12-38-23 AS cargo-install-stage
USER gitpod
RUN cargo install --root=/tmp/cargo-bin sccache cargo-udeps


## Merge artifacts and build the final image.
FROM gitpod/workspace-full:2022-12-15-12-38-23

ENV rust_nightly_date "2022-12-26"
ENV rust_version "nightly-${rust_nightly_date}"

LABEL org.opencontainers.image.title="The speed-optimized and feature-rich Rust Docker image for Gitpod."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.url="https://github.com/pan93412/gitpod-fast-rust-image"

USER gitpod

# Bind sh to bash
RUN sudo ln -fs /bin/bash /bin/sh

# Install nvim
RUN sudo install-packages neovim

# Update Image
RUN sudo apt update && \
    sudo apt upgrade -y &&  \
    sudo apt clean

# Install Rust nightly
RUN rustup self update && \
    rustup install ${rust_version} && \
    rustup default ${rust_version}

# Copy Cargo configuration to this image,
# and initiate this configuration when starting bash.
COPY ./config/config.toml /home/gitpod/.cargo/config.toml
COPY ./scripts/81-cargo-config /home/gitpod/.bashrc.d/

# Copy the prebuilt mold to /usr/local/
COPY --from=mold-stage /tmp/mold-bin /usr/local/

# Copy the prebuilt sccache & cargo-udeps to ~/.cargo/bin
COPY --from=cargo-install-stage /tmp/cargo-bin /home/gitpod/.cargo/
