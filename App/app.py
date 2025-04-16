from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route("/")
def index():
    # Get current UTC time in ISO format and client IP address
    now = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    ip_address = request.headers.get("X-Forwarded-For", request.remote_addr)
    return jsonify(timestamp=now, ip=ip_address)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
