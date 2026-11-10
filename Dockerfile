# Beancount v3 + Fava + statement importers, as a container image.
#   podman build -t beancount-stack:dev .
# The ledger is mounted at /data. No data is ever baked into the image.
FROM python:3.13-slim

# uv, pinned to the version that produced uv.lock
COPY --from=ghcr.io/astral-sh/uv:0.12.6 /uv /uvx /usr/local/bin/

# python-magic (used by the importers to sniff statement file types) needs libmagic at runtime
RUN apt-get update \
 && apt-get install -y --no-install-recommends libmagic1 \
 && rm -rf /var/lib/apt/lists/*

# install into the system environment, so fava and bean-* are on PATH for every entry point
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/usr/local \
    PYTHONUNBUFFERED=1 \
    TZ=UTC

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# non-root; uid 1000 matches other rootless services in the cluster
RUN groupadd -g 1000 beancount \
 && useradd -u 1000 -g 1000 -m -d /home/beancount -s /usr/sbin/nologin beancount \
 && mkdir -p /data \
 && chown 1000:1000 /data
USER 1000:1000
ENV HOME=/home/beancount
WORKDIR /data
EXPOSE 5000

ENTRYPOINT ["fava"]
CMD ["--host", "0.0.0.0", "--port", "5000", "/data/ledger.beancount"]
