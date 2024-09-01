import argparse
import json
from typing import List

from jinja2 import Environment
from jinja2 import FileSystemLoader


def generate_ob_config(env: Environment, master_onion_address: str) -> None:
    """
    Generate the ob_config file for Tor services.

    Args:
        env (Environment): Jinja2 Environment object.
        master_onion_address (str): The master onion address to be used in the config file.

    Returns: None
    """

    try:
        template = env.get_template("ob_config.template")
        output = template.render(master_onion_address=master_onion_address)
        with open("conf/ob_config", "w") as conf:
            conf.write(output)
        print("ob_config generated successfully.")
    except Exception as e:
        print(f"An error occurred while generating ob_config: {e}")


def generate_config(
    env: Environment,
    log_level: str,
    log_location: str,
    domains: List[str],
    key_path: str,
) -> None:
    """
    Generate the config.yaml file for OnionBalance.

    Args:
        env (Environment): Jinja2 Environment object.
        log_level (str): Log level for the config.
        log_location (str): Log file location for the config.
        domains (List[str]): List of backend domains for the config.
        key_path (str): Path to the secret key file for the config.

    Returns: None
    """

    # Displaying the domains before processing.
    print("Processing the following domains:")
    for domain in domains:
        print(domain)

    try:
        template = env.get_template("config.template")
        output = template.render(
            log_level=log_level,
            log_location=log_location,
            domains=domains,
            key_path=key_path,
        )
        with open("conf/config.yaml", "w") as conf:
            conf.write(output)
        print("config.yaml generated successfully.")
    except Exception as e:
        print(f"An error occurred while generating config.yaml: {e}")


def generate_monitor_config(env: Environment, master_onion_address: str) -> None:
    """
    Generate the monitor_config.sql file for Kuma.

    Args:
        env (Environment): Jinja2 Environment object.
        master_onion_address (str): The master onion address to be used in the config file.

    Returns: None
    """

    try:
        with open("bin/kuma/monitor.json", "r") as file:
            monitors = json.load(file)
    except FileNotFoundError:
        print("Error: monitor.json file not found.")
        exit(1)
    except json.JSONDecodeError:
        print("Error: monitor.json file is not a valid JSON.")
        exit(1)
    except Exception as e:
        print(f"An error occurred while loading monitor.json: {e}")
        exit(1)

    runtime_parameters = {"octo": {"url": master_onion_address}}

    for monitor in monitors:
        if monitor["name"] in runtime_parameters:
            monitor.update(runtime_parameters[monitor["name"]])

    try:
        template = env.get_template("monitor_config.template")
        output = template.render(monitors=monitors)
        with open("bin/kuma/scripts/monitor_config.sql", "w") as conf:
            conf.write(output)
        print("monitor_config generated successfully.")
    except Exception as e:
        print(f"An error occurred while generating monitor_config: {e}")


def prepare(args: argparse.Namespace):
    env = Environment(loader=FileSystemLoader("scripts/templates"))

    if args.config_type == "ob_config" or args.config_type == "all":
        generate_ob_config(env, args.master_onion_address)

    if args.config_type == "config" or args.config_type == "all":
        generate_config(
            env, args.log_level, args.log_location, args.domains, args.key_path
        )

    if args.config_type == "monitor_config" or args.config_type == "all":
        generate_monitor_config(env, args.master_onion_address)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate configuration files based on type and parameters."
    )
    parser.add_argument(
        "config_type",
        choices=["ob_config", "config", "monitor_config", "all"],
        help="Type of configuration to generate.",
    )
    parser.add_argument(
        "--master_onion_address", help="Master Onion Address for ob_config."
    )
    parser.add_argument("--log_level", help="Log level for the config.")
    parser.add_argument(
        "--log_location",
        help="Log file location for the config.",
    )
    parser.add_argument(
        "--domains",
        nargs="*",
        help="List of backend domains for the config.",
        default=[],
    )
    parser.add_argument(
        "--key_path",
        help="Path to the secret key file for the config.",
    )
    args = parser.parse_args()

    if (
        args.config_type == "ob_config"
        or args.config_type == "monitor_config"
        or args.config_type == "all"
    ) and not args.master_onion_address:
        parser.error("The --master_onion_address argument is required")

    prepare(args)
