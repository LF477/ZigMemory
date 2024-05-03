# syntax=docker/dockerfile:1

# https://docs.docker.com/go/dockerfile-reference/

################################################################################
FROM alpine:latest as base
# RUN apk add zig --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

################################################################################
# Create a stage for building/compiling the application.
# the Awesome Compose repository: https://github.com/docker/awesome-compose
# FROM base as build

FROM cgr.dev/chainguard/zig:latest-dev as builder
COPY --chown=nonroot . /app
WORKDIR /app
RUN zig build run

FROM cgr.dev/chainguard/static
COPY --from=builder /app/zig-out/bin/app /usr/local/bin/app
CMD ["/usr/local/bin/app"]

# RUN echo -e '#!/bin/sh\n\
# zig build' > /bin/build.sh
# RUN chmod +x /bin/build.sh

################################################################################
# Create a final stage for running your application.
FROM base AS final

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser
USER appuser

# Copy the executable from the "build" stage.
# COPY --from=build /bin/build.sh /bin/

# What the container should run when it is started.
# ENTRYPOINT [ "/bin/build.sh" ]
