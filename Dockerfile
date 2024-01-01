FROM python:3.10.9-slim AS base

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y git && apt-get clean

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

# set custom nodes
RUN mkdir -p /app/default_custom_nodes
RUN cd /app/default_custom_nodes && git clone https://github.com/zhangp365/ComfyUI-VideoHelperSuite.git

# set custom models
RUN mkdir -p /default_models/checkpoints
COPY ./models/checkpoints/svd_xt.safetensors /default_models/checkpoints

# set workflow
RUN mkdir /workflows
COPY ./workflows/svd.json /workflows

FROM base as base_ready

# Copy and enable all scripts
COPY ./scripts /scripts
RUN chmod +x /scripts/*

EXPOSE 8188
ENV ROOT=/app
WORKDIR ${ROOT}
# Required for Python print statements to appear in logs
ENV PYTHONUNBUFFERED=1
# Force variant layers to sync cache by setting --build-arg BUILD_DATE
ARG BUILD_DATE
ENV BUILD_DATE=$BUILD_DATE
RUN echo "$BUILD_DATE" > /build_date.txt

# Run
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]

FROM base_ready AS default
RUN echo "DEFAULT" >> /variant.txt
ENV CLI_ARGS=""
CMD echo "update successfully"