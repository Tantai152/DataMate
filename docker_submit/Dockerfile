FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        python3 python3-pip curl build-essential cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# requirements.txt phải có mặt trước khi pip đọc nó.
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# Cài llama-cpp-python hỗ trợ CUDA (phải build từ source với GGML_CUDA=on;
# wheel mặc định trên PyPI là bản CPU, --n_gpu_layers sẽ bị bỏ qua).
RUN CMAKE_ARGS="-DGGML_CUDA=on" pip3 install --no-cache-dir "llama-cpp-python[server]"

COPY src/ /app/src/
COPY rulebook.md /app/
COPY calendar.csv /app/
COPY README.md /app/
COPY run.sh /app/
# Model .gguf đặt sẵn trong docker_submit/models/ trước khi build.
COPY models/ /app/models/
RUN chmod +x /app/run.sh

ENTRYPOINT ["/app/run.sh"]
