import sys
import time
from stem.control import Controller


def is_tor_ready() -> bool:
    """
    Check if Tor is fully operational by checking the bootstrap phase.

    Returns:
        bool: True if Tor is fully operational, False otherwise.
    """
    try:
        with Controller.from_port(port=9051) as controller:
            controller.authenticate()
            bootstrap_phase = controller.get_info("status/bootstrap-phase")
            print(f"Current bootstrap phase: {bootstrap_phase}")
            return "PROGRESS=100" in bootstrap_phase and "TAG=done" in bootstrap_phase

    except Exception as e:
        print(f"Error checking Tor status: {e}")
        return False


if __name__ == "__main__":
    if is_tor_ready():
        print("Tor is fully operational.")
        sys.exit(0)  # (healthy)
    else:
        print("Tor is not fully operational.")
        sys.exit(1)  # (unhealthy)
