import os

from whisper_live.server import TranscriptionServer

os.environ.setdefault("OMP_NUM_THREADS", os.environ.get("OMP_NUM_THREADS", "4"))

# single_model: load tiny once, share across clients (faster warm connects, less RAM).
# max_clients=1: one live stream avoids CPU contention that causes caption lag on Pi/CPU.
TranscriptionServer().run(
    "0.0.0.0",
    port=9090,
    backend="faster_whisper",
    max_clients=1,
    max_connection_time=1800,
    single_model=True,
)
