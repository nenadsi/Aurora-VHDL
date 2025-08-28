import struct

def encode_write_reg(addr, value32):
    return bytes([0xAA, 0x01, addr & 0x0F]) + struct.pack('<I', value32 & 0xFFFFFFFF) + bytes([0x55])

def decode_status(payload: bytes):
    return {'raw': payload.hex()}
