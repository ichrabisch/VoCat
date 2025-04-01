from dataclasses import dataclass

from transformers import pipeline

from concurrent.futures import ThreadPoolExecutor, as_completed
from transformers.image_utils import load_image

@dataclass
class ParagraphParams:
    prompt_type:str
    target_audience:str
    vocab_list:list[str]
    max_attempts:int=3

class ParagraphGenerator:
    def __init__(self, model:pipeline, max_length:int=256, do_sample:bool=True):
        self.model = model
        self.max_length = max_length
        self.do_sample = do_sample

    def generate_paragraph_from_words(self, prompt: str):
        print(f"Generating paragraph from words: {prompt}")
        try:
            generated_text = self.model(prompt, max_length=self.max_length, do_sample=self.do_sample)[0]['generated_text']
            if not generated_text[-1] in '.!?':
                generated_text += '.'
            return generated_text
        except Exception as e:
            print(f"Generation error: {e}")

    def validate_paragraph(self, paragraph, vocab_list):
        """Check if all vocabulary words are used in the paragraph."""
        if not paragraph:
            return [], vocab_list
            
        paragraph_lower = paragraph.lower()
        used_words = []
        missing_words = []
        
        for word in vocab_list:
            if word.lower() in paragraph_lower:
                used_words.append(word)
            else:
                missing_words.append(word)
        
        return used_words, missing_words

    def generate_complete_paragraph(self, params:ParagraphParams):
        """Generate a paragraph and ensure all words are used."""
        best_paragraph = None
        max_words_used = 0
        prompt = f"Write a {params.prompt_type} for {params.target_audience} using these words: {params.vocab_list}.\
            Do not describe the words, you have to write a {params.prompt_type} in context of these words.\
            Infer the level of the text based on the words."

        for _ in range(params.max_attempts):
            paragraph = self.generate_paragraph_from_words(prompt)
            
            if paragraph:
                used_words, missing_words = self.validate_paragraph(paragraph, params.vocab_list)
                
                if len(used_words) > max_words_used:
                    max_words_used = len(used_words)
                    best_paragraph = paragraph
                
                if not missing_words:
                    return paragraph
        print(f"Best paragraph: {best_paragraph}")
        return best_paragraph