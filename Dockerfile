# syntax=docker/dockerfile:1
#
ARG PYTHON_VERSION="3.13"

FROM alpine:3.20 AS database
RUN apk update && apk add --no-cache sqlite
WORKDIR /app
ADD https://opendata.traficom.fi/Content/Ajoneuvorekisteri.zip /app/
ADD init_database.sh schema.sql /app/
RUN /bin/sh init_database.sh


FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=/app/uv.lock \
    --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
    uv sync --frozen --no-install-project --no-dev
ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable


FROM python:${PYTHON_VERSION}-alpine
COPY --from=builder /app/.venv /app/.venv
COPY --from=database /app/ajoneuvodata.sqlite /app/

ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000
CMD [ "gunicorn", "-w" , "2", "-b", "0.0.0.0:8000", "ajoneuvodata:app"]
