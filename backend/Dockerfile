FROM python:3.11-slim AS build
WORKDIR /w
ENV PIP_NO_CACHE_DIR=1
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --prefix=/opt/py -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/py/bin:$PATH"

# Security: run as non-root
RUN useradd -r -u 10001 appuser
COPY --from=build /opt/py /opt/py
COPY . .

# Persist DB file outside image if you want:
# VOLUME ["/app"]   # uncomment if you plan to mount /app/statuspulse.db

USER appuser
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
