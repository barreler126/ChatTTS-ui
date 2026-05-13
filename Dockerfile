# 使用 Python 3.10 官方镜像作为基础
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量（加速pip和避免缓冲）
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 从 GitHub 克隆 barreler126/ChatTTS-ui 项目
RUN git clone https://github.com/barreler126/ChatTTS-ui.git .

# 安装 Python 依赖
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# 安装 PyTorch（CPU 版本，如需 GPU 版本请修改）
RUN pip install torch==2.2.0 torchaudio==2.2.0 --index-url https://download.pytorch.org/whl/cpu

# 创建必要的目录
RUN mkdir -p /app/static/wavs \
    && mkdir -p /app/logs \
    && mkdir -p /app/speaker

# 设置 HuggingFace Spaces 环境变量
ENV WEB_ADDRESS=0.0.0.0:7860 \
    compile=false \
    device=cpu \
    merge_size=6

# 暴露端口
EXPOSE 7860

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860/ || exit 1

# 启动应用
CMD ["python", "app.py"]
