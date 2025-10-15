# ---- Builder Stage ----
FROM haskell:8.10-bookworm AS builder

# Update and install dependencies
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list || true && \
    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true -qq && \
    apt-get install -qq -y libpcre3 libpcre3-dev build-essential pkg-config curl --fix-missing --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /duckling
COPY . .

ENV LANG=C.UTF-8

# Set up and build
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
