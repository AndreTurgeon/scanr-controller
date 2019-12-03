from starlette.testclient import TestClient
import httpretty

from .app import app

client = TestClient(app)


def test_health_endpoint():
    response = client.head("/health")
    assert response.status_code == 200


def test_info_endpoint(monkeypatch):
    build_version = "1.0b17"
    monkeypatch.setenv("BUILD_VERSION", build_version)
    response = client.get("/info")
    assert response.status_code == 200
    assert response.json() == {
        "vendor": "Proofpoint",
        "product": "scanr",
        "version": build_version
    }


@httpretty.activate
def test_classifier_endpoint():
    # define your patch:
    body = {
        "body": "It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife",
        "found": []
    }
    httpretty.register_uri(httpretty.POST, "http://localhost:8088/classifier",
                           body=body)

    request = {
        "body": "It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife"
    }
    response = client.post("/classifier/pfpt", json=request)
    assert response.status_code == 200
    assert response.json() == {

    }
