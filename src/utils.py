import logging  
import subprocess
import json
from dotenv import load_dotenv
from urllib.parse import urlparse
import os
import time

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

def setup_logging():
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        '%(asctime)s.%(msecs)03d - %(levelname)s - %(name)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    handler.setFormatter(formatter)

    # Clear existing handlers and set the new one
    root_logger.handlers.clear()
    root_logger.addHandler(handler)

def get_file_paths(data_folder):
    """Get the file paths for each file in the data folder and save the result in an array."""
    file_paths = []

    for root, dirs, files in os.walk(data_folder):
        for file in files:
            file_path = os.path.join(root, file)
            file_paths.append(file_path)

    return file_paths

def enable_tracing(project_client, tracing="console"):
    if tracing == "console":
        from opentelemetry import trace
        project_client.telemetry.enable(destination=sys.stdout)
    elif tracing == "azure_monitor":
        from opentelemetry import trace
        from azure.monitor.opentelemetry import configure_azure_monitor

        application_insights_connection_string = project_client.telemetry.get_connection_string()
        if not application_insights_connection_string:
            print("Application Insights was not enabled for this project.")
            print("Enable it via the 'Tracing' tab in your AI Foundry project page.")
            exit()
        configure_azure_monitor(connection_string=application_insights_connection_string)

    scenario = os.path.basename(__file__)
    tracer = trace.get_tracer(__name__)
    return tracer, scenario

class RunAgent:
    def __init__(self, project_client, thread_id, agent_name, agent_instructions, user_message):
        self.project_client = project_client
        self.thread_id = thread_id
        self.agent_name = agent_name
        self.agent_instructions = agent_instructions
        self.user_message = user_message

    def create_agent(self):
        agent = self.project_client.agents.create_agent(
            model=os.environ["AZURE_AI_DEPLOYMENT_MODEL"],
            name=self.agent_name,
            instructions=self.agent_instructions
        )
        self.id = agent.id
        print(f"Created {self.agent_name} agent with agent ID: {agent.id}")
        return agent

    def create_message(self):
        message = self.project_client.agents.create_message(
            thread_id=self.thread_id,
            role="user",
            content=self.user_message
        )
        print(f"Created message, with message ID: {message.id}, on thread ID: {self.thread_id}")
        return message

    def create_run(self, agent_id):
        run = self.project_client.agents.create_run(
            thread_id=self.thread_id, 
            assistant_id=agent_id
        )
        print(f"Created run, with run ID: {run.id}, on thread ID: {self.thread_id}")

        # Poll the run as long as run status is queued or in progress
        while run.status in ["queued", "in_progress", "requires_action"]:
            # Wait for two seconds
            time.sleep(2)
            run = self.project_client.agents.get_run(thread_id=self.thread_id, run_id=run.id)

            print(f"Run status: {run.status}")

        return run

    def delete_agent(self, agent_id):
        self.project_client.agents.delete_agent(agent_id)
        print(f"Deleted agent {self.agent_name}")

def main():
    pass

if __name__ == "__main__":
    main()