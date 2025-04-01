from dataclasses import dataclass
from transformers import pipeline

from transformers.image_utils import load_image
import torch

@dataclass
class ImageParams:
    image_url:str

class ImageCaptioner:
    def __init__(self, model, processor):
        self.model = model
        self.processor = processor
    def caption_image(self, params:ImageParams):

        image = load_image(params.image_url)

        model_inputs = self.processor(text="", images=image, return_tensors="pt").to(torch.bfloat16)
        input_len = model_inputs["input_ids"].shape[-1]

        with torch.inference_mode():
            generation = self.model.generate(**model_inputs, max_new_tokens=100, do_sample=False)
            generation = generation[0][input_len:]
            decoded = self.processor.decode(generation, skip_special_tokens=True)
        return decoded