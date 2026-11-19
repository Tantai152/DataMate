#!/bin/bash
set -e

# 1. Bật Server LLM 14B (Model sẽ được mount sẵn trong thư mục /app/models)
echo "Starting LLM Server..."
python3 -m llama_cpp.server \
    --model /app/models/qwen2.5-coder-14b-instruct-q4_k_m.gguf \
    --host 0.0.0.0 --port 8000 \
    --n_gpu_layers -1 \
    --n_ctx 8192 \
    --n_threads 8 \
    --chat_format chatml > /tmp/llama_server.log 2>&1 &

# 2. Đợi Server sẵn sàng
echo "Waiting for LLM Server..."
while ! curl -s http://localhost:8000/v1/models > /dev/null; do
    sleep 2
done
echo "Server is Ready!"

# 3. Chạy DataMate
export USE_LLM=1
export LOCAL_LLM_BASE_URL="http://localhost:8000/v1"
export LOCAL_LLM_API_KEY="local"
export LOCAL_LLM_MODEL="local"

mkdir -p /tmp/db
mkdir -p /result

echo "Running DataMate..."
python3 -u /app/src/main.py \
    --data-root /data/data \
    --questions /data/questions.jsonl \
    --db-dir /tmp/db \
    --calendar /app/calendar.csv \
    --rulebook /app/rulebook.md \
    --prompt-budget 2500 \
    --max-fix 0 \
    --llm \
    --overwrite \
    --workers 2 \
    --out /result/submission.jsonl \
    --log /result/run_log.jsonl

echo "Done! Output saved to /result/submission.jsonl"
