"""
DESCRIPTION:
    This script demostrates how two Azure AI Foundry agents can work together to plan for a meal.

USAGE:
    python app_refactored.py

    Before running the sample, pip install the required packages from requirements.txt.
"""

import os, sys, datetime
from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import MessageTextContent
from azure.identity import DefaultAzureCredential
sys.path.append("..")
from utils import load_azd_env, set_azure_ai_project_connection_string, setup_logging, enable_tracing, RunAgent

# Load environment variables
load_azd_env()

# Set the connection string
set_azure_ai_project_connection_string()

# Enable logging
enbale_logging = False
if enbale_logging:
    setup_logging()

# Create a project client
project_client = AIProjectClient.from_connection_string(
    credential=DefaultAzureCredential(),
    conn_str=os.environ["AZURE_AI_FOUNDRY_CONNECTION_STRING"],
)

# Enable tracing
tracer, scenario = enable_tracing(project_client,"azure_monitor")

with tracer.start_as_current_span(scenario):
    with project_client:
        try:
            thread = project_client.agents.create_thread()
            print(f"Created thread, thread ID: {thread.id}")

            # Create and run meal planner agent
            meal_planner_agent = RunAgent(
                project_client=project_client,
                thread_id=thread.id,
                agent_name="meal_planner",
                agent_instructions=
                """
                    You are helpful AI assistant, specialist in creating nutritious and delicious meal plans.
                    You are a culinary enthusiast dedicated to promoting healthy eating habits, you have extensive knowledge of nutrition and a passion for crafting delightful meals.
                    Your meal plan will include breakfast, lunch and dinner with nutritional information for each meal.
                    You will not plan for snacks.
                """,
                user_message=
                """
                    Create a weekend meal plan for 25 years old male athlete that balances nutrition and taste. One day it will be 'seafood' day, the other day will be 'meat' day.
                """
            )
            meal_planner_agent.create_agent()
            meal_planner_agent.create_message()
            meal_planner_agent.create_run(agent_id=meal_planner_agent.id)
            meal_planner_agent.delete_agent(agent_id=meal_planner_agent.id)

            # Create and run groceries shopper agent
            groceries_shopper_agent = RunAgent(
                project_client=project_client,
                thread_id=thread.id,
                agent_name="groceries_shopper",
                agent_instructions=
                """
                    You are helpful AI assistant, specialist in making sure that all ingredients are readily available for cooking.
                    You are a meticulous organizer with a keen eye for detail, you excel at sourcing high-quality ingredients and ensuring the pantry is always stocked.
                """,
                user_message=
                """
                    Create a comprehensive shopping list with quantities and specific items needed for the weekend meal plan.
                """
            )
            groceries_shopper_agent.create_agent()
            groceries_shopper_agent.create_message()
            groceries_shopper_agent.create_run(agent_id=groceries_shopper_agent.id)
            groceries_shopper_agent.delete_agent(agent_id=groceries_shopper_agent.id)

            # Ensure the directory exists
            os.makedirs('../meal-plans', exist_ok=True)

            messages = project_client.agents.list_messages(thread_id=thread.id)
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
            filename = f'../meal-plans/meal-planner_{timestamp}.md'
            with open(filename, 'w') as file:
                for data_point in reversed(messages.data):
                    last_message_content = data_point.content[-1]
                    if isinstance(last_message_content, MessageTextContent):
                        # output = f"""**{data_point.role}:**\n\n---\n\n{last_message_content.text.value.strip()}\n\n"""
                        # print(output)
                        # file.write(output)
                        if data_point.role == 'user':
                            icon = '👤'
                        elif data_point.role == 'assistant':
                            icon = '🤖'
                        else:
                            icon = ''
                        output = f"""**{icon} {data_point.role}:**\n\n---\n\n{last_message_content.text.value.strip()}\n\n"""
                        print(output)
                        file.write(output)

        except:
            # Print details of error message
            print(f"An error occurred: {sys.exc_info()[0]}")
            pass