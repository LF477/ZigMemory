# syntax=docker/dockerfile:1

# https://docs.docker.com/go/dockerfile-reference/

################################################################################
FROM alpine:3.13 as base

RUN apk update && \
    apk add \
        tar \
        curl \
        xz

ARG ZIGVER
RUN mkdir -p /deps
WORKDIR /deps
RUN curl https://ziglang.org/deps/zig+llvm+lld+clang-$(uname -m)-linux-musl-$ZIGVER.tar.xz  -O && \
    tar -xf zig+llvm+lld+clang-$(uname -m)-linux-musl-$ZIGVER.tar.xz && \
    mv zig+llvm+lld+clang-$(uname -m)-linux-musl-$ZIGVER/ local/

################################################################################
# Create a stage for building/compiling the application.
# the Awesome Compose repository: https://github.com/docker/awesome-compose
FROM base as build
RUN echo -e '#!/bin/sh\n\
zig build'\
> /bin/build.sh
RUN chmod +x /bin/build.sh

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
# COPY --from=base /deps/local/ /deps/local/
COPY --from=build /bin/build.sh /bin/

# What the container should run when it is started.
ENTRYPOINT [ "/bin/build.sh" ]
