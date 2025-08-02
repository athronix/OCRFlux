from flask import Flask, request, jsonify
from functools import wraps
import jwt
import datetime
from config import *
from ocrflux.client import request
import asyncio
from argparse import Namespace

app = Flask(__name__)


# JWT token required decorator
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"message": "Token is missing!"}), 401
        try:
            data = jwt.decode(token.split()[1], SECRET_KEY, algorithms=["HS256"])
        except:
            return jsonify({"message": "Token is invalid!"}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/ocrflux', methods=['POST'])
@token_required
def ocrflux_api():
    if not request.json or 'file_path' not in request.json:
        return jsonify({"status": "error", "message": "File path is required"}), 400
    
    file_path = request.json['file_path']
    try:
        result = ocrflux(file_path)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    

async def ocrflux(file_path: str):
    if not file_path:
        raise ValueError("File path is required")
    args = Namespace(
        model=ocrflux_model,
        skip_cross_page_merge=skip_cross_page_merge,
        max_page_retries=max_page_retries,
        url=vllm_url,
        port=vllm_srv_port,
    )
    result = asyncio.run(request(args,file_path))
    return result

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)