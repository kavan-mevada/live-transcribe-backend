# CPU WhisperLive server (arm64 + amd64). PyPI install, no git clone.
FROM python:3.12-slim-bookworm

ARG WHISPER_LIVE_VERSION=0.9.0

ENV PYTHONUNBUFFERED=1 \
    OMP_NUM_THREADS=4

RUN apt-get update \
    && apt-get install -y --no-install-recommends portaudio19-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# CPU torch first; whisper-live --no-deps avoids nvidia/cu12 wheels on Linux.
RUN pip install --no-cache-dir -U pip \
    && pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir "whisper-live==${WHISPER_LIVE_VERSION}" --no-deps \
    && pip install --no-cache-dir \
        faster-whisper==1.2.0 \
        websockets \
        onnxruntime \
        numba \
        kaldialign \
        soundfile \
        scipy \
        av \
        jiwer \
        evaluate \
        "numpy<2" \
        tokenizers==0.20.3 \
        fastapi \
        uvicorn \
        python-multipart \
        openai-whisper==20250625 \
        websocket-client

# Latency tuning on the installed package.
RUN WHISPER_DIR="$(python -c 'import whisper_live, os; print(os.path.dirname(whisper_live.__file__))')" \
    && sed -i 's/duration < 1.0/duration < 0.5/' "$WHISPER_DIR/backend/base.py" \
    && sed -i 's/time.sleep(0.1)  # wait for audio chunks/time.sleep(0.02)  # wait for audio chunks/' "$WHISPER_DIR/backend/base.py" \
    && sed -i 's/word_timestamps=self.word_timestamps)/word_timestamps=self.word_timestamps, beam_size=1, best_of=1)/' "$WHISPER_DIR/backend/faster_whisper_backend.py"

COPY server.py /app/server.py

EXPOSE 9090
VOLUME ["/root/.cache/whisper-live"]

CMD ["python", "server.py"]
