from flask import Flask, request, jsonify
app = Flask(__name__)
seen = {}
@app.post("/payments")
def pay():
    k = request.headers.get("Idempotency-Key")
    if k in seen: return jsonify(seen[k])
    seen[k] = {"id": f"pay_{len(seen)+1:04d}", "status": "authorized"}
    return jsonify(seen[k]), 201
if __name__ == "__main__": app.run(port=5002)
