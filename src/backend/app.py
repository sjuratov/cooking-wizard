import os
import sys 
import logging
from dotenv import load_dotenv  
from fastapi import FastAPI, HTTPException, Body  
from fastapi.responses import JSONResponse
sys.path.append("..")
from utils import load_azd_env, set_azure_ai_project_connection_string

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
   
# Load environment variables from a .env file
load_azd_env()

# Set the connection string for the Azure AI project
set_azure_ai_project_connection_string()

app = FastAPI()

@app.post("/echo")
async def echo(request_body: dict = Body(...)):
    logging.info('HTTP trigger function started processing a request.')
  
    # Extract parameters from the request body  
    msg = request_body.get('msg')
  
    # Validate required parameters
    if not msg:
        raise HTTPException(status_code=400, detail="<msg> is required!")
  
    return JSONResponse(  
        content={"echo_msg": f'Echo: {msg}'},  
        status_code=200  
    )  

if __name__ == "__main__":  
    import uvicorn  
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True, log_config=None)  