# syntax=docker/dockerfile:1

# https://docs.docker.com/go/dockerfile-reference/

################################################################################
FROM alpine:latest as base
RUN apk add zig --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

################################################################################
# Create a stage for building/compiling the application.
# the Awesome Compose repository: https://github.com/docker/awesome-compose
# add build step, where you build your container and push it to registry (read more about container registry in Github!)
FROM base as build
ADD ./ app/
WORKDIR /app
RUN zig build
VOLUME [ "/app" ]

################################################################################
# add test step, where you pull your container and execute tests on your application
FROM base as test
WORKDIR /
COPY --from=build /app/src/ /app/src
COPY --from=build /app/build.zig /app/build.zig
WORKDIR /app
RUN zig build test

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
COPY --from=build /app/zig-out/bin/ /
COPY --from=test /app/src/ /tests/src/
COPY --from=test /app/build.zig /tests/build.zig
ADD src/ /testss/src
ADD ./build.zig /tests/build.zig

# What the container should run when it is started.
CMD [ "zig", "build", "test" ] 
