# ---------- 1. Build Stage ----------
FROM python:3.11-slim AS build

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY . .

# ---------- 2. Runtime Stage ----------
FROM python:3.11-slim AS runtime

WORKDIR /app

# Copy installed packages and app source from build stage
COPY --from=build /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=build /app /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

EXPOSE 8000

# Command to run the backend server
CMD ["python", "main.py"]
