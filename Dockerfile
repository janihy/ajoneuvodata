# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app
RUN apt-get update && apt-get install -y sqlite3 wget unzip

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev
ADD . /app
RUN ./init_database.sh
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable

FROM python:3.13-slim
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/ajoneuvodata.sqlite /app/

ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000
CMD [ "gunicorn", "-w" , "2", "-b", "0.0.0.0:8000", "ajoneuvodata:app"]
