import os
import sys
import argparse
import logging


def setup_logger():
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
    )


def parse_arguments():
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


def find_hidden_service_dir(torrc_path):
    if not os.path.exists(torrc_path):
        logging.error(f"The torrc file at {torrc_path} was not found.")
        sys.exit(1)

    with open(torrc_path, "r") as file:
        for line in file:
            if "HiddenServiceDir" in line:
                return line.strip().split()[1]

    logging.error("HiddenServiceDir not found in torrc file.")
    sys.exit(1)


def get_onion_hostname(hidden_service_dir):
    hostname_path = os.path.join(hidden_service_dir, "hostname")
    if not os.path.exists(hostname_path):
        logging.error(f"The hostname file at {hostname_path} was not found.")
        sys.exit(1)

    with open(hostname_path, "r") as file:
        return file.read().strip()


def main():
    setup_logger()
    args = parse_arguments()
    hidden_service_dir = find_hidden_service_dir(args.torrc_path)

    print(get_onion_hostname(hidden_service_dir))


if __name__ == "__main__":
    main()
