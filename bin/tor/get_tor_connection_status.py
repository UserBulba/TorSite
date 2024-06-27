import time
import debugpy
from stem import Signal
from stem.connection import connect_port
from stem.control import Controller

debugpy.listen(("0.0.0.0", 5678))  # nosec
debugpy.wait_for_client()
logger.debug("Waiting for debugger attach")

def is_tor_ready():
    try:
        # Connect to Tor using cookie authentication (no password needed)
        with Controller.from_port(port=9051) as controller:
            controller.authenticate()  # Automatically uses cookie authentication if available
            # Check if Tor has fully bootstrapped
            return (
                controller.is_alive()
                and controller.get_info("status/bootstrap-phase") == "tag=done"
            )
    except Exception as e:
        print(f"Error checking Tor status: {e}")
        return False


if __name__ == "__main__":
    while not is_tor_ready():
        print("Waiting for Tor to be fully operational...")
        time.sleep(5)
    print("Tor is fully operational.")
