from multiprocessing import freeze_support
import torch
from fastapi import FastAPI, File, UploadFile
from paragraph_generator import ParagraphGenerator, ParagraphParams
from image_captioner import ImageCaptioner
from transformers import (
    PaliGemmaProcessor,
    PaliGemmaForConditionalGeneration,
    pipeline
)
import uvicorn
from image_captioner import ImageParams

checkpoint = "MBZUAI/LaMini-Flan-T5-248M"
paragraph_generator = None

app = FastAPI()

@app.post("/generate_paragraph")
def generate_paragraph(params: ParagraphParams):
    global paragraph_generator
    if paragraph_generator is None:
        model = pipeline('text2text-generation', model=checkpoint)
        paragraph_generator = ParagraphGenerator(model=model, max_length=256, do_sample=True)
        print("Paragraph generator initialized")
    print(f"Paragraph generator: {params}")
    return paragraph_generator.generate_complete_paragraph(params)

@app.post("/caption_image")
def caption_image(params: ImageParams):
    return image_captioner.caption_image(params)

if __name__ == "__main__":
    #image_captioner = ImageCaptioner(model=PaliGemmaForConditionalGeneration.from_pretrained("google/paligemma2-3b-pt-224", torch_dtype=torch.bfloat16).eval(),
                                    #processor=PaliGemmaProcessor.from_pretrained("google/paligemma2-3b-pt-224"))
    
    model = pipeline('text2text-generation', model=checkpoint)
    paragraph_generator = ParagraphGenerator(model=model, max_length=256, do_sample=True)

    uvicorn.run("main:app", host="0.0.0.0", port=8000, workers=1, reload=True)
