import os
import sys

from jinja2 import Environment
from jinja2 import FileSystemLoader


def main():
    if len(sys.argv) < 3:
        print("Usage: python config_generator.py [config_type] [hostname] [domains...]")
        sys.exit(1)

    config_type = sys.argv[1]  # 'ob_config', 'config', or 'all'
    hostname = sys.argv[2]
    domains = sys.argv[3:]  # Domains are optional and may be empty

    print(f"Configuration type requested: {config_type}")
    print(f"Received OnionBalance domain: {hostname}")
    if domains:
        print("Received backend domains:")
        for domain in domains:
            print(domain)

    # Set up Jinja2 environment
    env = Environment(loader=FileSystemLoader("scripts/templates"))

    # Generate configurations based on the specified type
    if config_type == "ob_config" or config_type == "all":
        generate_ob_config(env, hostname)
    if config_type == "config" or config_type == "all":
        if domains:
            generate_config(env, domains, hostname)
        else:
            print("No domains provided for config.yaml generation.")


def generate_ob_config(env, hostname):
    try:
        template = env.get_template("ob_config.template")
        output = template.render(master_onion_address=hostname)
        with open("conf/ob_config", "w") as conf:
            conf.write(output)
        print("ob_config generated successfully.")
    except Exception as e:
        print(f"An error occurred while generating ob_config: {e}")


def generate_config(env, domains, hostname):
    try:
        template = env.get_template("config.template")
        output = template.render(domains=domains, key=hostname)
        with open("conf/config.yaml", "w") as conf:
            conf.write(output)
        print("config.yaml generated successfully.")
    except Exception as e:
        print(f"An error occurred while generating config.yaml: {e}")


if __name__ == "__main__":
    main()
