## Build mold
FROM gitpod/workspace-c AS mold-stage
COPY ./scripts/mold/common.sh ./scripts/mold/build.sh ./
RUN bash build.sh

## Build packages installed with `cargo install`
FROM gitpod/workspace-rust AS cargo-install-stage
COPY ./scripts/cargo-install/build.sh ./
RUN bash build.sh

## Merge artifacts.
FROM gitpod/workspace-full

LABEL org.opencontainers.image.title="The speed-optimized and feature-rich Rust Docker image for Gitpod."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.url="https://github.com/pan93412/gitpod-fast-rust-image"

# Copy the intermediates from the above stages.
COPY --from=mold-stage /tmp/gitpod-mold-rust-image /tmp/gitpod-mold-rust-image
COPY --from=cargo-install-stage /tmp/cargo-pkgs /tmp/cargo-pkgs

# Copy the scripts from our repo.
COPY ./scripts/mold/common.sh   \
     ./scripts/mold/install.sh  \
     ./scripts/mold/clean.sh    \
     ./mold/
COPY ./scripts/cargo-install/install.sh ./cargo-install/
COPY ./scripts/bind-sh-to-bash/install.sh ./bind-sh-to-bash/

# Run installation scripts
RUN \
    bash ./mold/install.sh && bash ./mold/clean.sh && \
    bash ./cargo-install/install.sh && \
    bash ./bind-sh-to-bash/install.sh

# Clean up
RUN sudo rm -rf ./mold/ ./cargo-install/ ./bind-sh-to-bash/

# Copy Cargo configuration to this image
COPY ./config/config.toml /workspace/.cargo/config.toml
