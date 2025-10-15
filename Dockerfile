# ---- Builder Stage ----
FROM haskell:8.10-bullseye AS builder

RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libpcre3-dev build-essential pkg-config --fix-missing --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /duckling
COPY . .

ENV LANG=C.UTF-8

RUN stack setup
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
