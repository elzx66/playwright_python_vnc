FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

# 设置代理参数
ARG HTTPS_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY
ENV HTTP_PROXY=$HTTPS_PROXY
ENV NO_PROXY=localhost,127.0.0.1

ENV DEBIAN_FRONTEND=noninteractive

# Install additional system dependencies for Xvfb, VNC, and window manager
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install optional dependencies for Playwright
RUN apt-get update && apt-get install -y \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libxcomposite1 \
    libxrandr2 \
    libxdamage1 \
    libxkbcommon-x11-0 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entry_point.sh .

# Install Playwright with --break-system-packages flag to bypass PEP 668 restrictions in Docker container
RUN pip install --break-system-packages playwright==1.51.0

# Set executable permissions
RUN chmod +x entry_point.sh

# Set default Chinese font
RUN mkdir -p /etc/fonts/conf.d && cat > /etc/fonts/conf.d/99-chinese-font.conf <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test qual="any" name="family">
      <string>sans-serif</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>WenQuanYi Zen Hei</string>
      <string>WenQuanYi Zen Hei Mono</string>
    </edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family">
      <string>serif</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>WenQuanYi Zen Hei</string>
    </edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>WenQuanYi Zen Hei Mono</string>
    </edit>
  </match>
</fontconfig>
EOF

# Update font cache
RUN fc-cache -fv

# Ensure Playwright and its dependencies are installed
RUN playwright install --with-deps

# Ensure directories are writable
RUN mkdir -p /app/user_data/
RUN mkdir -p /app/user_data/
RUN mkdir -p /shared
RUN chmod -R 777 /app/user_data
RUN mkdir -p /shared

# Environment variables
ENV DISPLAY=:99
ENV USER_DATA_DIR=/app/user_data

# Expose ports
EXPOSE 5900

# Default command
CMD ["/app/entry_point.sh"]