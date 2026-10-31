FROM docker.io/supercorp/supergateway:4.2.0-uvx
# the image's python 3.12 satisfies >=3.11 (.python-version says 3.11); never fetch another one
ENV UV_PYTHON_DOWNLOADS=never
WORKDIR /src
COPY . ./
RUN UV_PROJECT_ENVIRONMENT=/opt/venv uv sync --python /usr/bin/python3 --frozen --no-dev --no-editable --no-cache \
  && rm -rf /src
WORKDIR /
USER 65534:65534
# a service account only, on the read-only scope: Google refuses every write
ENV GSC_READ_ONLY=true \
  GSC_SKIP_OAUTH=true \
  GSC_ALLOW_DESTRUCTIVE=false \
  GSC_CONFIG_DIR=/tmp/mcp-gsc \
  HOME=/tmp
EXPOSE 8000
CMD ["--stdio", "/opt/venv/bin/mcp-gsc", "--outputTransport", "streamableHttp", "--port", "8000", "--healthEndpoint", "/healthz"]
