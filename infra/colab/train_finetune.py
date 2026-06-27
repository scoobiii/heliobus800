"""
Fine-tuning qwen2.5-coder:0.5b para agentes HelioBus800
Roda no Google Colab T4 (gratuito)
Após treino: baixe o .gguf e registre no Ollama do Termux

Passos:
  1. Colab > Runtime > Change runtime type > T4 GPU
  2. Cole e execute cada bloco abaixo
  3. Baixe hb800-agent-gguf/model.gguf
  4. No Termux:
       mkdir -p ~/heliobus800/models
       mv ~/downloads/model.gguf ~/heliobus800/models/
       ollama create hb800-agent -f ~/heliobus800/models/Modelfile
       ollama run hb800-agent "Qual é o PUE alvo?"
"""

INSTALL = "!pip install unsloth datasets trl -q"

LOAD = """
from unsloth import FastLanguageModel
import torch
model, tokenizer = FastLanguageModel.from_pretrained(
    "Qwen/Qwen2.5-Coder-0.5B-Instruct",
    max_seq_length=2048, dtype=torch.float16, load_in_4bit=True)
model = FastLanguageModel.get_peft_model(model, r=16,
    target_modules=["q_proj","v_proj"], lora_alpha=16,
    use_gradient_checkpointing=True)
"""

DATASET = """
from datasets import Dataset
examples = [
  {"text": "### Instrução:\\nQual é a temperatura de supply do loop?\\n### Input:\\nDew point SP verão 24°C\\n### Resposta:\\nMínimo 27°C (margem 3°C sobre dew point 24°C). Fonte: docs/KPI.md"},
  {"text": "### Instrução:\\nPUE está em 1.20. O que fazer?\\n### Input:\\nSite GPA CD1\\n### Resposta:\\nALERTA: PUE 1.20 acima do limite 1.15 (docs/KPI.md). Ação: verificar inverter, checar loop 18-22°C, auditar cargas parasitas. Escalando laura_ee."},
  {"text": "### Instrução:\\nQual topologia 800VDC escolher?\\n### Input:\\n\\n### Resposta:\\nDado não disponível — decisão BLOCKER pendente (mês 2). Opções: Diablo (OCP) vs NVIDIA monopolar. Encaminhando para bruno_cto. Fonte: docs/OCP_REFERENCE.md"},
]
dataset = Dataset.from_list(examples)
"""

TRAIN = """
from trl import SFTTrainer
from transformers import TrainingArguments
trainer = SFTTrainer(model=model, tokenizer=tokenizer,
    train_dataset=dataset, dataset_text_field="text",
    args=TrainingArguments(output_dir="./out", num_train_epochs=3,
        per_device_train_batch_size=2, fp16=True))
trainer.train()
"""

EXPORT = """
model.save_pretrained_gguf("hb800-agent-gguf", tokenizer, quantization_method="q4_k_m")
from google.colab import files
import glob
for f in glob.glob("hb800-agent-gguf/*.gguf"):
    files.download(f)
"""

MODELFILE = """
FROM ./model.gguf
SYSTEM "Agente HelioBus800 — zero alucinação, cite fontes docs/. Se incerto: 'Dado não disponível.'"
PARAMETER temperature 0.1
PARAMETER num_ctx 2048
"""
