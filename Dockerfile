FROM python:3.10-slim-buster

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    APP_HOME=/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME
COPY . .

RUN pip install -U pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && rm -rf /root/.cache

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
