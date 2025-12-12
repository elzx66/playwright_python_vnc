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

# ─────────────────────────────────────────────
# 💡 ENV & SETUP HELPERS
# ─────────────────────────────────────────────
# Load from .env if it exists
if [ -f "/app/.env" ]; then
    echo "📥 Loading environment from .env"
    set -o allexport
    source /app/.env
    set +o allexport
fi


export DISPLAY=${DISPLAY:-:99}
export USER_DATA_DIR=${USER_DATA_DIR:-/app/user_data}
export SCREEN_RES=${SCREEN_RES:-1280x1024x24}


setup_dirs() {
    mkdir -p "$USER_DATA_DIR" /shared
    chmod -R 777 "$USER_DATA_DIR" /shared
}

check_env() {
    if [ ! -d "/app" ]; then
        echo "❌ Must run inside container."
        exit 1
    fi
    echo "✅ Working in /app"
    echo "✅ DISPLAY=$DISPLAY"
    echo "✅ USER_DATA_DIR=$USER_DATA_DIR"
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
# 🧹 CLEANUP
# ─────────────────────────────────────────────

cleanup_services() {
    echo "🧹 Stopping services..."
    kill $FLUXBOX_PID $X11VNC_PID $XVFB_PID 2>/dev/null
}

trap cleanup_services INT TERM EXIT

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
