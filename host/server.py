import argparse, time
from flask import Flask, send_from_directory, request, jsonify
import serial
from serial_proto import encode_write_reg, decode_status

app = Flask(__name__, static_folder='web', static_url_path='')

ser = None

@app.route('/')
def index():
    return send_from_directory('web', 'index.html')

@app.route('/status')
def status():
    return jsonify({'ok': True})

@app.route('/api/params', methods=['POST'])
def api_params():
    data = request.json or {}
    max_iter = int(data.get('max_iter', 128)) & 0xFF
    ser.write(encode_write_reg(3, max_iter))
    return jsonify({'ok': True, 'max_iter': max_iter})

def main():
    global ser
    ap = argparse.ArgumentParser()
    ap.add_argument('--port', required=True, help='Serial port e.g., /dev/ttyUSB0 or COM3')
    ap.add_argument('--baud', type=int, default=115200)
    ap.add_argument('--host', default='127.0.0.1')
    ap.add_argument('--webport', type=int, default=5000)
    args = ap.parse_args()
    ser = serial.Serial(args.port, args.baud, timeout=0.1)
    print('[AuroraVHDL] Serial opened at', args.port)
    app.run(host=args.host, port=args.webport, debug=True)

if __name__ == '__main__':
    main()
