import logging  
import subprocess
import json
from dotenv import load_dotenv
from urllib.parse import urlparse
import os

def load_azd_env():
    """Get path to current azd env file and load file using python-dotenv"""
    result = subprocess.run("azd env list -o json", shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        logging.info(f"azd binary present")
        env_json = json.loads(result.stdout)
        env_file_path = None
        for entry in env_json:
            logging.info(f"azd entry found: {entry}")
            if entry["IsDefault"]:
                env_file_path = entry["DotEnvPath"]
        if not env_file_path:
            logging.info(f"azd environment not present. reverting to plain dotenv")
            load_dotenv()
        load_dotenv(env_file_path, override=True)
    else:
        logging.info(f"azd binary not found. reverting to plain dotenv")
        load_dotenv()

def set_azure_ai_project_connection_string():
    """Set the connection string for the Azure AI project"""
    parsed_discovery_url = urlparse(os.getenv("AZURE_AI_FOUNDRY_DISCOVERY_URL"))
    DISCOVERY_FQDN = parsed_discovery_url.hostname
    AZURE_SUBSCRIPTION_ID = os.getenv("AZURE_SUBSCRIPTION_ID")
    AZURE_RESOURCE_GROUP = os.getenv("AZURE_RESOURCE_GROUP")
    AZURE_AI_FOUNDRY_PROJECT_NAME = os.getenv("AZURE_AI_FOUNDRY_PROJECT_NAME")
    
    AZURE_AI_FOUNDRY_CONNECTION_STRING = f"{DISCOVERY_FQDN};{AZURE_SUBSCRIPTION_ID};{AZURE_RESOURCE_GROUP};{AZURE_AI_FOUNDRY_PROJECT_NAME}"
    os.environ["AZURE_AI_FOUNDRY_CONNECTION_STRING"] = AZURE_AI_FOUNDRY_CONNECTION_STRING

def main():
    pass

if __name__ == "__main__":
    main()