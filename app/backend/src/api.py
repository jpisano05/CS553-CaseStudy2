from fastapi import FastAPI
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel
from huggingface_hub import InferenceClient
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import torch

#globals
SYSTEM_PROMPT = '''You are a coffee expert. Based on a user's taste profile, recommend them a type of coffee or espresso based drink.
                        1. The type of coffee bean (origin and variety)
                        2. The brew method
                        3. The type of drink
                        
                        Give a single paragraph and be short and specific.'''
EXAMPLE_INPUT = '''Bright and citrusy'''
EXAMPLE_OUTPUT = '''I recommend a medium-bodied Ethiopian Yirgacheffe brewed as a pour-over and served as a latte, highlighting bright citrus and floral notes.'''


global pipe
    
MODEL_ID = "Qwen/Qwen2.5-0.5B-Instruct"
device = "cuda" if torch.cuda.is_available() else "cpu"

tokenizer = AutoTokenizer.from_pretrained(MODEL_ID, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(
    MODEL_ID,
    trust_remote_code=True,
    torch_dtype=torch.float16 if device == "cuda" else torch.float32,
).to(device)

pipe = pipeline("text-generation", model=model, tokenizer=tokenizer)

app = FastAPI()

#setup pydantic models
class localRequest(BaseModel):
    message: str
    max_tokens: int

class apiRequest(BaseModel):
    message: str
    max_tokens: int
    hf_token: str

#simple get for checking status
@app.get("/", response_class = PlainTextResponse)
async def health():
    return "Running"

#calling the local version of the model
@app.post("/local")
def runLocalModel(request: localRequest):
    #run local model
    
    message = request.message
    max_tokens = request.max_tokens
    
    USER_PROMPT = message
    
    chat = [
        {'role': 'system', 'content': SYSTEM_PROMPT},
        {'role': 'user', 'content': EXAMPLE_INPUT},
        {'role': 'assistant', 'content': EXAMPLE_OUTPUT},
        {'role': 'user', 'content': USER_PROMPT}
    ]
        
    outputs = pipe(
        chat,
        do_sample=False,
        max_new_tokens=max_tokens
    )

        
    response = outputs[0]['generated_text'][-1]['content'].strip()
    
    return response

#calling the API version of the model
@app.post("/api")
def runAPIModel(request: apiRequest):
    #run api model

    message = request.message
    max_tokens = request.max_tokens
    hf_token = request.hf_token

    USER_PROMPT = message
    
    chat = [
        {'role': 'system', 'content': SYSTEM_PROMPT},
        {'role': 'user', 'content': EXAMPLE_INPUT},
        {'role': 'assistant', 'content': EXAMPLE_OUTPUT},
        {'role': 'user', 'content': USER_PROMPT}
    ]

    client = InferenceClient(
        token=hf_token,
        model="openai/gpt-oss-20b",
    )

    completion = client.chat_completion(
        messages=chat,
        max_tokens=max_tokens,
        stream=False,
    )
            
    response = completion.choices[0].message.content.strip()
    return response