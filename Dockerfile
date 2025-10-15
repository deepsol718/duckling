# ---- Builder Stage ----
FROM haskell:9.12.2-bookworm AS builder

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -qq -y libpcre3 libpcre3-dev build-essential pkg-config curl --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /duckling
COPY . .

ENV LANG=C.UTF-8

# Stack setup and build
RUN stack setup && stack build --only-dependencies
RUN stack install

# ---- Runtime Stage ----
FROM debian:bookworm

ENV LANG C.UTF-8

RUN apt-get update -qq && \
    apt-get install -qq -y libpcre3 libgmp10 --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /root/.local/bin/duckling-example-exe /usr/local/bin/

EXPOSE 8000

CMD ["duckling-example-exe", "-p", "8000"]
