
# StatusPulse Slim Pack

This pack removes heavyweight artifacts and aligns persistence paths so EC2 disk usage stays low.

## What changed

- Removed `backend/statuspulse.db` from the repository. The app now persists at `/data/statuspulse.db` inside the container.
- Ensured `docker-compose.yml` and `docker-compose.app.yml` mount a **named volume** to `/data`.
- Added `frontend/.dockerignore` to keep Docker build context minimal.

## Deploy notes

- Your backend image expects SQLite at `/data/statuspulse.db`. The compose files now mount:
  ```yaml
  volumes:
    - statuspulse_data:/data
  ```

- On EC2, prune old images periodically:
  ```bash
  docker system prune -af --volumes
  ```

- For even more savings, move Docker's data-root to a larger disk (e.g., /mnt) using `/etc/docker/daemon.json`:
  ```json
  { "data-root": "/mnt/docker-data" }
  ```
  Then restart Docker:
  ```bash
  sudo systemctl restart docker
  ```
