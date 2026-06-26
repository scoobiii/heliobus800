# Dockerfile — HelioBus800 monitoring agent
# ARM64 (Termux/proot) e amd64 compatível
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/monitoring/agent.py ./monitoring/agent.py
COPY dashboard/config.production.json ./dashboard/config.production.json

ENV PYTHONUNBUFFERED=1
EXPOSE 8080

CMD ["python", "monitoring/agent.py"]
