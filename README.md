# live-transcribe-backend

Public WhisperLive CPU server for [live-transcribe](https://github.com/kavan-mevada/live-transcribe). The web app connects via WebSocket on port **9090**.

## Image

**`ghcr.io/kavan-mevada/live-transcribe-backend:latest`**

Built on push to `main` by [`.github/workflows/docker.yml`](.github/workflows/docker.yml).

Make this GitHub repo and its GHCR package **public** so Raspberry Pi can `podman pull` without login.

## Build locally

```bash
docker build -t live-transcribe-backend .
docker run --rm -p 9090:9090 live-transcribe-backend
```

## Podman Quadlet (`whisperlive.container`)

Save as `~/.config/containers/systemd/whisperlive.container`:

```ini
[Unit]
Description=WhisperLive
After=network-online.target

[Container]
Image=ghcr.io/kavan-mevada/live-transcribe-backend:latest
ContainerName=whisperlive
PublishPort=0.0.0.0:9090:9090
Volume=whisperlive-cache:/root/.cache/whisper-live
Environment=OMP_NUM_THREADS=4

[Service]
Restart=always

[Install]
WantedBy=default.target
```

## Deploy on Raspberry Pi 5

Requires Podman and user systemd (`systemctl --user`).

```bash
mkdir -p ~/.config/containers/systemd
# Create whisperlive.container using the unit above

systemctl --user disable --now whisperlive-collabora.service 2>/dev/null || true

podman pull ghcr.io/kavan-mevada/live-transcribe-backend:latest

loginctl enable-linger $USER
systemctl --user daemon-reload
systemctl --user enable --now whisperlive.service
```

## Verify

```bash
systemctl --user status whisperlive.service
journalctl --user -u whisperlive.service -f
nc -vz $(hostname -I | awk '{print $1}') 9090
```

WebSocket URL: `ws://<pi-ip>:9090`
