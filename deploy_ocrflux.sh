sudo apt-get update
sudo apt-get install poppler-utils poppler-data ttf-mscorefonts-installer msttcorefonts fonts-crosextra-caladea fonts-crosextra-carlito gsfonts lcdf-typetools

conda activate ocrflux

git clone https://github.com/chatdoc-com/OCRFlux.git
cd OCRFlux

pip install -e . --find-links https://flashinfer.ai/whl/cu124/torch2.5/flashinfer/

pip install huggingface_hub

mkdir -p ~/models

python -c "
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='ChatDOC/OCRFlux-3B',
    local_dir='/home/Ubuntu/models/OCRFlux-3B'
)
"

python -m ocrflux.pipeline ./localworkspace --data test.pdf --model ~/models/OCRFlux-3B
python -m ocrflux.pipeline ./localworkspace --data /home/Ubuntu/Downloads/test.pdf --model ~/models/OCRFlux-3B
cat ~/OCRFlux/localworkspace/results/*.jsonl
