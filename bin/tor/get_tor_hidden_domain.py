import os
import sys
import argparse
import logging


def setup_logger() -> None:
    """
    Setup the logger to print the log messages to the console.

    Returns:
        None
    """
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
    )


def parse_arguments() -> argparse.Namespace:
    """
    Parse the command-line arguments.

    Returns:
        argparse.Namespace: The parsed arguments.
    """
    parser = argparse.ArgumentParser(
        description="Fetch the .onion hostname from a Tor hidden service."
    )
    parser.add_argument(
        "torrc_path",
        nargs="?",
        default="/etc/tor/torrc",
        help="Path to the Tor configuration file (default: /etc/tor/torrc)",
    )
    return parser.parse_args()


def find_hidden_service_dir(torrc_path: str) -> str:
    """
    Find the directory where the hidden service files are stored.

    Args:
        torrc_path (str): The path to the torrc file.

    Returns:
        str: The path to the hidden service directory.
    """
    if not os.path.exists(torrc_path):
        logging.error(f"The torrc file at {torrc_path} was not found.")
        sys.exit(1)

    with open(torrc_path, "r") as file:
        for line in file:
            if "HiddenServiceDir" in line:
                return line.strip().split()[1]

    logging.error("HiddenServiceDir not found in torrc file.")
    sys.exit(1)


def get_onion_hostname(hidden_service_dir: str) -> str:
    """
    Get the .onion hostname from the hidden service directory.

    Args:
        hidden_service_dir (str): The path to the hidden service directory.

    Returns:
        str: The .onion hostname.
    """
    hostname_path = os.path.join(hidden_service_dir, "hostname")
    if not os.path.exists(hostname_path):
        logging.error(f"The hostname file at {hostname_path} was not found.")
        sys.exit(1)

    with open(hostname_path, "r") as file:
        return file.read().strip()


def main() -> None:
    """
    Main function to get the .onion hostname from a Tor hidden service.
    """
    setup_logger()
    args = parse_arguments()
    hidden_service_dir = find_hidden_service_dir(args.torrc_path)

    print(get_onion_hostname(hidden_service_dir))


if __name__ == "__main__":
    main()
