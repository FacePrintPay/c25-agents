#!/bin/bash
cat > output/ollama_c25_model.sh << 'OLLAMA'
#!/bin/bash
pkg install curl -y
curl -fsSL https://ollama.com/install.sh | sh
ollama pull tinyllama
ollama serve &
echo "✅ PATHOS: Offline LLM ready at localhost:11434"
OLLAMA
chmod +x output/ollama_c25_model.sh
echo "✅ PATHOS: Offline inference script generated"
