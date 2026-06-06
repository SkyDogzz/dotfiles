# AI Models — SkyDogzz Laptop (2026)

## Hardware

| Component | Model |
|-----------|-------|
| **CPU** | AMD Ryzen 7 7840HS (8C/16T) |
| **RAM** | 30 GB |
| **GPU** | AMD Radeon RX 7600 (8 GB VRAM, RDNA 3) |

---

## LLM — Text Inference

Backend: `ollama` (auto ROCm) or `hipfire` (Rust+HIP, 9x faster on Qwen3.5 DeltaNet)

| Task | Model | Quant | VRAM | Tok/s |
|------|-------|-------|------|-------|
| **Chat / General assistant** | Qwen3.5-9B | Q4_K_M | ~6.1 GB | ~38 |
| **Code** | Qwen2.5-Coder 7B | Q4_K_M | ~5.0 GB | ~42 |
| **Reasoning / Math** | DeepSeek-R1 Distill 7B | Q4_K_M | ~5.0 GB | ~40 |
| **RAG / Long documents** | Qwen3.5-9B | Q4_K_M | ~6.1–7.0 GB | ~38 |
| **Multilingual** | Qwen3 8B | Q4_K_M | ~6.2 GB | ~38 |
| **Small & fast** | Qwen3.5-4B | Q4_K_M | ~3.5 GB | ~60+ |
| **Vision (image→text)** | Qwen3.5-9B *(natif)* | Q4_K_M | ~6.1 GB | ~38 |
| **JSON / Function calling** | Mistral 7B v0.3 | Q4_K_M | ~4.8 GB | ~42 |

---

## Image Generation

Backend: `comfyui` (ROCm) or `automatic1111` (DirectML/Vulkan)

| Task | Model | VRAM | Resolution | Time | Notes |
|------|-------|------|------------|------|-------|
| **General generation** | SDXL | ~6 GB | 1024×1024 | ~7–10s | Best quality/speed balance |
| **Fast / Real-time** | SDXL Turbo | ~6 GB | 1024×1024 | ~2–3s | 1–4 steps, near instant |
| **Photorealistic** | SD3.5 Medium | ~7 GB | 1024×1024 | ~10–15s | 2.6B params, barely fits |
| **Animation / Style** | SD 1.5 | ~4 GB | 512×512 | ~3–5s | Huge LoRA ecosystem |
| **Prompt following** | FLUX.1 Schnell | ~7.5 GB | 512×512 | ~8–12s | Tight fit for 8 GB |
| **Inpainting / Editing** | SDXL Inpainting | ~6 GB | 1024×1024 | ~7–10s | Mask + regenerate |

### ComfyUI Setup (recommended)

```bash
git clone https://github.com/comfyanonymous/ComfyUI ~/ComfyUI
cd ~/ComfyUI
pip install -r requirements.txt
python main.py  # --force-fp16 for AMD ROCm
```

### Models to download

| Model | File | Size |
|-------|------|------|
| **SDXL** | `sd_xl_base_1.0.safetensors` | ~6.9 GB |
| **SDXL Turbo** | `sd_xl_turbo_1.0_fp16.safetensors` | ~6.9 GB |
| **SD3.5 Medium** | `sd3.5_medium.safetensors` | ~6.5 GB |
| **FLUX.1 Schnell** | `flux1-schnell.safetensors` | ~7.5 GB |

All available on [huggingface.co](https://huggingface.co) or [civitai.com](https://civitai.com).
