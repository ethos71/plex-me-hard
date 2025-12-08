FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install rclone for Google Drive
RUN curl https://rclone.org/install.sh | bash

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY converter.py .
COPY sync_gdrive.sh .
RUN chmod +x sync_gdrive.sh

CMD ["python", "-u", "converter.py"]
