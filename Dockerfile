FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

# 设置代理参数
# ARG HTTPS_PROXY
# ENV HTTPS_PROXY=$HTTPS_PROXY
# ENV HTTP_PROXY=$HTTPS_PROXY
# ENV NO_PROXY=localhost,127.0.0.1

# 设置中文语言环境
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

# Install additional system dependencies for Xvfb, VNC, window manager, Chinese language support, terminal emulator, and supervisord
RUN apt-get update && apt-get install -y \ 
    xvfb \ 
    x11vnc \ 
    fluxbox \ 
    vim \ 
    xterm \ 
    language-pack-zh-hans \ 
    language-pack-zh-hans-base \ 
    locales \ 
    supervisor \ 
    # Chinese input method support
    fcitx5 \ 
    fcitx5-chinese-addons \ 
    fcitx5-frontend-gtk3 \ 
    fcitx5-frontend-qt5 \ 
    fcitx5-pinyin \ 
    # Chinese fonts
    fonts-wqy-zenhei \ 
    fonts-wqy-microhei \ 
    && rm -rf /var/lib/apt/lists/*

# Configure Chinese locale
RUN locale-gen zh_CN.UTF-8

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
    \
    # Install Chinese language packs for browsers
    chromium-browser-l10n \
    firefox-locale-zh-hans \
    \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entry_point.sh .

# Set executable permissions
RUN chmod +x entry_point.sh

# Install Playwright with --break-system-packages flag to bypass PEP 668 restrictions in Docker container
RUN pip install --break-system-packages playwright==1.51.0

# Ensure Playwright and its dependencies are installed with Chinese language support
RUN playwright install --with-deps chromium

# Configure Chromium to use Chinese language by default
# RUN mkdir -p /app/chromium_config
# RUN echo '{"intl": {"accept_languages": "zh-CN,zh"}}' > /app/chromium_config/locale.json
# ENV CHROMIUM_FLAGS="--lang=zh-CN --user-data-dir=/app/user_data"

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
      <string>WenQuanYi Micro Hei</string>
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

# Configure Chinese input method environment variables
ENV GTK_IM_MODULE=fcitx5
ENV QT_IM_MODULE=fcitx5
ENV XMODIFIERS=@im=fcitx5
ENV INPUT_METHOD=fcitx5
ENV XIM=fcitx5
ENV XIM_PROGRAM=fcitx5

# Update font cache
RUN fc-cache -fv

# Ensure directories are writable
# RUN mkdir -p /app/user_data/
# RUN mkdir -p /app/user_data/
# RUN mkdir -p /shared
# RUN chmod -R 777 /app/user_data
# RUN mkdir -p /shared

# # Environment variables
# ENV DISPLAY=:99
# ENV USER_DATA_DIR=/app/user_data

# Expose ports
EXPOSE 5900

# Create supervisord configuration file
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/

# Configure Fluxbox menu
RUN mkdir -p /root/.fluxbox
COPY fluxbox_ownmenu /root/.fluxbox/menu
RUN chmod +x /root/.fluxbox/menu

# Configure fcitx5 input method
RUN mkdir -p /root/.config/fcitx5/conf
RUN cat > /root/.config/fcitx5/profile <<EOF
[Group/0]
Name=Default
DefaultIM=pinyin

[Groups]
Default=0

[Hotkey]
TriggerKey=CTRL_SHIFT

[InputMethod/pinyin]
Enabled=True
LangCode=zh_CN
Name=Pinyin
Parent=fcitx5-pinyin
EOF

RUN cat > /root/.config/fcitx5/conf/classicui.conf <<EOF
# 界面语言
Locale=zh_CN

# 显示输入法名称
DisplayLanguageName=True

# 主窗口位置
MainWindowPosition=0

# 候选词数量
VerticalListCandidateCount=5

# 字体
Font="WenQuanYi Zen Hei 12"
EOF

# Default command
CMD ["/app/entry_point.sh"]