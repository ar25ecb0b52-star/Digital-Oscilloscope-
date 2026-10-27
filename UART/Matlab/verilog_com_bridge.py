import time
import serial

SIM_FILE_PATH = "uart_tx_out.bin"
VIRTUAL_PORT  = "COM10"
BAUD_RATE     = 115200

def run_verilog_bridge():
    ser = serial.Serial(VIRTUAL_PORT, BAUD_RATE)
    print(f"[Bridge] Connected to {VIRTUAL_PORT} at {BAUD_RATE} baud.")
    print(f"[Bridge] Tailing {SIM_FILE_PATH} -> streaming to MATLAB on COM11...")
    
    with open(SIM_FILE_PATH, "rb") as f:
        while True:
            chunk = f.read(64)
            if chunk:
                ser.write(chunk)
            else:
                time.sleep(0.001)

if __name__ == "__main__":
    run_verilog_bridge()