"""
DESCRIPTION:
    This script demostrates how two Azure AI Foundry agents can work together to plan for a meal.

USAGE:
    python app.py

    Before running the sample, pip install the required packages from requirements.txt.
"""

import os, time
from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import MessageTextContent
from azure.identity import DefaultAzureCredential

# Adapt scripts to work with local environment
# START
import sys
sys.path.append("..")
from utils import load_azd_env, set_azure_ai_project_connection_string, setup_logging
load_azd_env()

set_azure_ai_project_connection_string()

enbale_logging = False
if enbale_logging:
    setup_logging()
# END

project_client = AIProjectClient.from_connection_string(
    credential=DefaultAzureCredential(),
    conn_str=os.environ["AZURE_AI_FOUNDRY_CONNECTION_STRING"],
)

# Set the tracing to "console" or "azure_monitor"
# START
tracing = "azure_monitor"

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
# END

with tracer.start_as_current_span(scenario):
    with project_client:
        try:
            # Create meal planner agent
            meal_planner = project_client.agents.create_agent(
                model=os.environ["AZURE_AI_DEPLOYMENT_MODEL"],
                name="meal_planner",
                instructions=
                """
                    You are helpful AI assistant, specialist in creating nutritious and delicious meal plans.
                    You are a culinary enthusiast dedicated to promoting healthy eating habits, you have extensive knowledge of nutrition and a passion for crafting delightful meals.
                    Your meal plan will include breakfast, lunch and dinner with nutritional information for each meal.
                    You will not plan for snacks.
                """
            )
            print(f"Created meal planner agent with agent ID: {meal_planner.id}")

            thread = project_client.agents.create_thread()
            print(f"Created thread, thread ID: {thread.id}")

            message = project_client.agents.create_message(
                thread_id=thread.id,
                role="user",
                content=
                """
                    Create a weekend meal plan for 55 years adult that balances nutrition and taste. One day it will be 'pasta' day, the other day will be 'stake' day.
                """
                )
            
            print(f"Created message, message ID: {message.id}")

            run = project_client.agents.create_run(
                thread_id=thread.id, 
                assistant_id=meal_planner.id
                )

            # Poll the run as long as run status is queued or in progress
            while run.status in ["queued", "in_progress", "requires_action"]:
                # Wait for two seconds
                time.sleep(2)
                run = project_client.agents.get_run(thread_id=thread.id, run_id=run.id)

                print(f"Run status: {run.status}")

            project_client.agents.delete_agent(meal_planner.id)
            print("Deleted agent")

            # Create groceries shopper agent
            groceries_shopper = project_client.agents.create_agent(
                model=os.environ["AZURE_AI_DEPLOYMENT_MODEL"],
                name="groceries_shopper",
                instructions=
                """
                    You are helpful AI assistant, specialist in making sure that all ingredients are readily available for cooking.
                    You are a meticulous organizer with a keen eye for detail, you excel at sourcing high-quality ingredients and ensuring the pantry is always stocked.
                """
            )

            print(f"Created groceries planner agent with agent ID: {groceries_shopper.id}")

            message = project_client.agents.create_message(
                thread_id=thread.id,
                role="user",
                content=
                """
                    You will wait for meal_planner agent to create meal plan, and then you will create a comprehensive shopping list with quantities and specific items needed for the weekend meal plan.
                """
                )
            
            print(f"Created message, message ID: {message.id}")

            run = project_client.agents.create_run(
                thread_id=thread.id, 
                assistant_id=groceries_shopper.id
                )

            # Poll the run as long as run status is queued or in progress
            while run.status in ["queued", "in_progress", "requires_action"]:
                # Wait for two seconds
                time.sleep(2)
                run = project_client.agents.get_run(thread_id=thread.id, run_id=run.id)

                print(f"Run status: {run.status}")

            project_client.agents.delete_agent(groceries_shopper.id)
            print("Deleted agent")

            messages = project_client.agents.list_messages(thread_id=thread.id)
            #print(f"Messages after groceries shopper has completed processing: {messages}")
            for data_point in reversed(messages.data):
                last_message_content = data_point.content[-1]
                if isinstance(last_message_content, MessageTextContent):
                    print(f"{data_point.role}:\n{last_message_content.text.value}")

        except:
            pass