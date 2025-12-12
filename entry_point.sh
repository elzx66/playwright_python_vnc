#!/bin/bash
set -e
# ┌────────────────────────────────────────────────────────┐
# │ PyPlayVNC - GhostBrowser for entrypoint.sh 🚀         │
# └────────────────────────────────────────────────────────┘

cat <<'EOF'
 ____        ____  _           __     ___   _  ____              
|  _ \ _   _|  _ \| | __ _ _   \ \   / / \ | |/ ___|              
| |_) | | | | |_) | |/ _` | | | \ \ / /|  \| | |      _____      
|  __/| |_| |  __/| | (_| | |_| |\ V / | |\  | |___  |_____|     
|_|    \__, |_|   |_|\__,_|\__, | \_/  |_| \_|\____|              
  ____ |___/           _   |___/                                 
 / ___| |__   ___  ___| |_| __ ) _ __ _____      _____  ___ _ __ 
| |  _| '_ \ / _ \/ __| __|  _ \| '__/ _ \ \ /\ / / __|/ _ \ '__|
| |_| | | | | (_) \__ \ |_| |_) | | | (_) \ V  V /\__ \  __/ |   
 \____|_| |_|\___/|___/\__|____/|_|  \___/ \_/\_/ |___/\___|_|   

🐍 Python + 🎭 Playwright + 🖥️ VNC + 📦 Xvfb + 🎛️ Fluxbox + 🔧 Supervisor
Dockerhub - shashankrawlani/playwright_python_vnc
EOF

export DISPLAY=${DISPLAY:-:99}
export SCREEN_RES=${SCREEN_RES:-1280x1024x24}
export USER_DATA_DIR=${USER_DATA_DIR:-/app/user_data}
export SHARED_DIR=${SHARED_DIR:-/shared}

# ibus environment variables
export QT_IM_MODULE=ibus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus



check_env() {
    if [ ! -d "/app" ]; then
        echo "❌ Must run inside container."
        exit 1
    fi
    echo "✅ Working in /app"
    echo "✅ DISPLAY=$DISPLAY"
    echo "✅ SCREEN_RES=$SCREEN_RES"
    echo "✅ USER_DATA_DIR=$USER_DATA_DIR"
    echo "✅ SHARED_DIR=$SHARED_DIR"
}


setup_dirs() {
    mkdir -p "$USER_DATA_DIR" "$SHARED_DIR"
    chmod -R 777 "$USER_DATA_DIR" "$SHARED_DIR" 
}

# ─────────────────────────────────────────────
# 🎛 INITIALIZATION (Services managed by Supervisor)
# ─────────────────────────────────────────────

# No need for start functions as services are managed by Supervisor

# ─────────────────────────────────────────────
# 🔍 ENVIRONMENT CHECKS
# ─────────────────────────────────────────────

env_check() {
    echo ""
    echo "🐍 Python version:" && python --version
    echo ""
    echo "🎭 Playwright via Python:"
    python -c "import importlib.metadata as m; print('✅ Python Playwright version:', m.version('playwright'))" 2>/dev/null || echo "❌ Not found"
    echo ""
    echo "🎭 Playwright CLI:"
    playwright --version || echo "❌ CLI not found"
    echo ""
    echo "✅ Environment check complete!"
}

# ─────────────────────────────────────────────
# 🚀 BOOTSTRAP
# ─────────────────────────────────────────────

check_env
setup_dirs
env_check

# Services are now managed by Supervisor
# This script just initializes the environment and exits
# Supervisor will start and manage all services

echo "🚀 Initialization complete! Starting Supervisor to manage all services..."

# Start supervisord to manage services
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
