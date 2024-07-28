import argparse
from typing import List

from jinja2 import Environment
from jinja2 import FileSystemLoader


def generate_ob_config(env: Environment, master_onion_address: str):
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
):

    # Displaying the domains for verification before processing
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


def main(args: argparse.Namespace):
    env = Environment(loader=FileSystemLoader("scripts/templates"))

    if args.config_type == "ob_config" or args.config_type == "all":
        generate_ob_config(env, args.master_onion_address)

    if args.config_type == "config" or args.config_type == "all":
        generate_config(
            env, args.log_level, args.log_location, args.domains, args.key_path
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate configuration files based on type and parameters."
    )
    parser.add_argument(
        "config_type",
        choices=["ob_config", "config", "all"],
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

    # Ensure that master_onion_address is provided for ob_config
    if (
        args.config_type == "ob_config" or args.config_type == "all"
    ) and not args.master_onion_address:
        parser.error(
            "The --master_onion_address argument is required for 'ob_config' or 'all'"
        )

    main(args)
