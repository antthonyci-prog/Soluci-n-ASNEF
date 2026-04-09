#!/bin/bash
# Script de Setup Automático para ASNEF (para usuarios técnicos)
# Uso: bash setup.sh

echo "🚀 ASNEF - Setup Script"
echo "======================"
echo ""

echo "1. Verificando archivos requeridos..."
files=("index.html" "styles.css" "script.js" "auth-config.js" "site-config.js" "lead-config.js")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file encontrado"
    else
        echo "   ❌ ERROR: $file NO encontrado"
        exit 1
    fi
done

echo ""
echo "2. Verificando conexión a internet..."
if ping -c 1 supabase.com &> /dev/null; then
    echo "   ✅ Conexión OK"
else
    echo "   ⚠️  Sin conexión a Supabase"
fi

echo ""
echo "3. Pasos siguientes:"
echo "   1. Ve a https://supabase.com y crea un proyecto"
echo "   2. Copia la URL y Anon Key"
echo "   3. Abre auth-config.js y pega los valores"
echo "   4. Abre site-config.js y completa tus datos"
echo "   5. Ejecuta 'python -m http.server 8000' para probar localmente"
echo "   6. Abre http://localhost:8000 en navegador"
echo ""
echo "✨ Setup listo para empezar"
