# syntax=docker/dockerfile:1
#
ARG PYTHON_VERSION="3.13"
ARG ALPINE_VERSION="3.21"

FROM alpine:${ALPINE_VERSION} AS database
RUN apk update && apk add --no-cache sqlite
WORKDIR /app
ADD https://opendata.traficom.fi/Content/Ajoneuvorekisteri.zip /app/
ADD init_database.sh schema.sql /app/
# TODO: this script isn't fully alpine-compatible
RUN /bin/sh init_database.sh


FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS builder
COPY --from=ghcr.io/astral-sh/uv:0.7.3 /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app
ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=/app/uv.lock \
    --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
    uv sync --frozen --no-dev --no-editable


FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}
COPY --from=builder /app/.venv /app/.venv
COPY --from=database /app/ajoneuvodata.sqlite /app/

ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000
CMD [ "gunicorn", "-w" , "2", "-b", "0.0.0.0:8000", "ajoneuvodata:app"]
