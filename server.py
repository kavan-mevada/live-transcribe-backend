import os

from whisper_live.server import TranscriptionServer

os.environ.setdefault("OMP_NUM_THREADS", os.environ.get("OMP_NUM_THREADS", "4"))

TranscriptionServer().run(
    "0.0.0.0",
    port=9090,
    backend="faster_whisper",
    max_clients=2,
    max_connection_time=1800,
)
