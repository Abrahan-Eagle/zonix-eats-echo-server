#!/bin/bash

# Zonix Echo Server - Script de inicio
echo "🚀 Iniciando Zonix Echo Server..."

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js no está instalado"
    exit 1
fi

# Verificar si npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm no está instalado"
    exit 1
fi

# Verificar si las dependencias están instaladas
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
fi

# Iniciar el servidor
echo "🔧 Iniciando servidor en modo desarrollo..."
echo "📡 Puerto: 6001"
echo "🌐 WebSocket: ws://localhost:6001"
echo ""

npm run start:dev 