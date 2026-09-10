import os
import sys
import time
import json
import urllib.request
import subprocess
from pathlib import Path

# Force UTF-8 output encoding for Windows terminal
sys.stdout.reconfigure(encoding='utf-8')

PORT = 8005
BASE_DIR = Path(__file__).resolve().parent
APP_CONSTANTS_PATH = BASE_DIR / "mobile" / "lib" / "core" / "constants" / "app_constants.dart"
BACKEND_DIR = BASE_DIR / "backend"

def get_ngrok_url():
    try:
        req = urllib.request.urlopen("http://127.0.0.1:4040/api/tunnels")
        data = json.loads(req.read().decode())
        tunnels = data.get("tunnels", [])
        for t in tunnels:
            if t.get("proto") == "https":
                return t.get("public_url")
            elif t.get("public_url"):
                return t.get("public_url")
    except Exception:
        pass
    return None

def update_flutter_constants(ngrok_url: str):
    if not APP_CONSTANTS_PATH.exists():
        print(f"[!] Could not find {APP_CONSTANTS_PATH}")
        return False
    
    content = APP_CONSTANTS_PATH.read_text(encoding="utf-8")
    new_base_url = f"{ngrok_url}/api/v1"
    
    import re
    updated_content = re.sub(
        r"static const String baseUrl = '.*?';",
        f"static const String baseUrl = '{new_base_url}';",
        content
    )
    
    APP_CONSTANTS_PATH.write_text(updated_content, encoding="utf-8")
    print(f"[+] Updated Flutter baseUrl to: {new_base_url}")
    return True

def main():
    print("==================================================")
    print("  BOTMARTZ AI - Local Backend & Ngrok Manager  ")
    print("==================================================")
    
    # 1. Check if backend is listening on PORT
    try:
        urllib.request.urlopen(f"http://localhost:{PORT}/health", timeout=2)
        print(f"[+] Notification Backend is running on http://localhost:{PORT}")
    except Exception:
        print(f"[*] Starting FastAPI Notification Backend on port {PORT}...")
        subprocess.Popen(
            [sys.executable, "-m", "uvicorn", "app.main:app", "--reload", "--port", str(PORT)],
            cwd=str(BACKEND_DIR)
        )
        time.sleep(3)

    # 2. Check if Ngrok is running
    url = get_ngrok_url()
    if not url:
        print(f"[*] Starting Ngrok Tunnel on port {PORT}...")
        subprocess.Popen(["ngrok", "http", str(PORT)], cwd=str(BASE_DIR))
        time.sleep(3)
        url = get_ngrok_url()

    if url:
        print("\n[>>>] TUNNEL ONLINE!")
        print(f"      Public Backend URL : {url}")
        print(f"      API Base Endpoint  : {url}/api/v1")
        print(f"      Swagger Docs       : {url}/docs")
        
        # 3. Auto update Flutter constants
        update_flutter_constants(url)
        print("\n[+] Mobile app config updated successfully! You can now test with physical mobile / emulator.")
    else:
        print("[-] Could not obtain Ngrok URL. Make sure ngrok is installed.")

if __name__ == "__main__":
    main()
