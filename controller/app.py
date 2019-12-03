import logging
import sys
from os import getenv, path

import requests
from dotenv import load_dotenv
from fastapi import FastAPI
from scanr.common.api import ModelInfo, NormalizedMessage
from starlette.responses import Response
from starlette.status import HTTP_200_OK

dotenv_path = path.join(path.dirname(__file__), '..', '.env')
if path.exists(dotenv_path):
    load_dotenv(dotenv_path)


customerIds = {
    "pfpt": "http://model:8080",
    "rjf": "http://model:8080"
}
app = FastAPI()

logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)


@app.post("/classifier/{customer_id}")
def read_item(customer_id: str, msg: NormalizedMessage) -> NormalizedMessage:
    url = customerIds[customer_id] + '/classifier'
    response = requests.post(url, json=msg.dict(skip_defaults=True))
    if response.ok:
        return response.json()
    else:
        return response.text


@app.get("/info")
def info() -> ModelInfo:
    return ModelInfo(vendor="Proofpoint",
                     product="scanr",
                     version=getenv("BUILD_VERSION"))


@app.head("/health")
def health_check():
    return Response(status_code=HTTP_200_OK)
