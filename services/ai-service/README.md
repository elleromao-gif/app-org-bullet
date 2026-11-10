# AI gateway

Create a Python virtual environment and install FastAPI:
```bash
python -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn pydantic pytest httpx
```

The AI gateway accepts narrowly scoped context and returns schema-validated proposals. It must not have direct database write credentials.
