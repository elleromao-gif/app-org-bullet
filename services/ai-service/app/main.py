from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(title="Compass AI Gateway", version="0.1.0")


class InterpretRequest(BaseModel):
    text: str = Field(min_length=1, max_length=10000)
    locale: str = "en"
    allowed_context_ids: list[str] = []


class InterpretResponse(BaseModel):
    status: str
    message: str


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/v1/interpret", response_model=InterpretResponse)
async def interpret(payload: InterpretRequest) -> InterpretResponse:
    # TODO: route through provider adapters and return a validated proposal.
    # Do not persist user data from this service.
    return InterpretResponse(
        status="not_implemented",
        message="AI interpretation adapter is not configured yet.",
    )
