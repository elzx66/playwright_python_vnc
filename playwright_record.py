from playwright.sync_api import sync_playwright
import  os

if __name__ == "__main__":

    #1. 定义 Chromium 启动参数（拆分原 CHROMIUM_FLAGS 为列表）
    chromium_args = [
        "--enable-features=UseChromeOSDirectVideoDecoder",
        "--disable-web-security",
        "--lang=zh-CN",  # 中文语言/输入法核心参数
        "--no-sandbox",  # 容器环境必需，否则 Chromium 无法启动
        "--disable-dev-shm-usage",  # 解决容器 /dev/shm 空间不足
        "--disable-extensions-file-access-check",
        "--disable-extensions-http-throttling-security",
        # 额外补充中文输入法适配参数（针对 IBUS/Fluxbox）
        "--enable-ime-api-for-all-frames",  # 启用输入法API
        "--ozone-platform=x11",  # 适配 Fluxbox 的 X11 环境
        "--disable-blink-features=AutomationControlled"  # 可选：避免被检测为自动化环境
        "--enable-ime-api-for-all-frames",  # 启用输入法API
        "--enable-features=WebRTCRTCInboundRtpEncoding,PlatformImeAndroid",
        "--enable-oop-ime",
        "--enable-system-ime",
        "--disable-setuid-sandbox"
    ]

    # 2. 配置环境变量（传递 IBUS 相关变量，确保输入法生效）
    custom_env = os.environ.copy()
    custom_env.update({
        "GTK_IM_MODULE": "ibus",
        "QT_IM_MODULE": "ibus",
        "XMODIFIERS": "@im=ibus",
        "LANG": "zh-CN.UTF-8"  # 系统语言
    })

    USER_DATA_DIR = os.getenv("USER_DATA_DIR", "/app/user_data")
    with sync_playwright() as p:
        ct = p.chromium.launch_persistent_context(
            USER_DATA_DIR,
            headless=False,
            args=["--start-maximized"] + chromium_args,  # 合并启动参数
            env=custom_env  # 传递环境变量
            )
        
        pg = ct.new_page()
        pg.goto("https://cn.bing.com")

        pg.pause()


