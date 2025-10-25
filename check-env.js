// Script para verificar variáveis de ambiente
const fs = require('fs');
const path = require('path');

console.log('='.repeat(50));
console.log('VERIFICAÇÃO DE VARIÁVEIS DE AMBIENTE');
console.log('='.repeat(50));

// 1. Verificar se arquivo existe
const envPath = path.join(__dirname, '.env.local');
console.log('\n1. Verificando arquivo .env.local...');
console.log('   Caminho:', envPath);

if (fs.existsSync(envPath)) {
  console.log('   ✅ Arquivo existe!');
  
  // 2. Ler conteúdo
  const content = fs.readFileSync(envPath, 'utf8');
  console.log('\n2. Conteúdo do arquivo:');
  console.log('   ---');
  console.log(content);
  console.log('   ---');
  
  // 3. Verificar se tem a chave
  if (content.includes('GEMINI_API_KEY')) {
    console.log('\n3. ✅ GEMINI_API_KEY encontrada no arquivo');
    
    // Extrair valor
    const match = content.match(/GEMINI_API_KEY=(.+)/);
    if (match) {
      const key = match[1].trim();
      console.log('   Tamanho da chave:', key.length, 'caracteres');
      console.log('   Preview:', key.substring(0, 10) + '...');
    }
  } else {
    console.log('\n3. ❌ GEMINI_API_KEY NÃO encontrada no arquivo');
  }
} else {
  console.log('   ❌ Arquivo NÃO existe!');
  console.log('\n   SOLUÇÃO:');
  console.log('   Crie o arquivo .env.local na raiz do projeto com:');
  console.log('   GEMINI_API_KEY=sua_chave_aqui');
}

// 4. Verificar process.env
console.log('\n4. Verificando process.env...');
if (process.env.GEMINI_API_KEY) {
  console.log('   ✅ GEMINI_API_KEY está em process.env');
  console.log('   Tamanho:', process.env.GEMINI_API_KEY.length, 'caracteres');
} else {
  console.log('   ❌ GEMINI_API_KEY NÃO está em process.env');
  console.log('   (Isso é normal - Next.js carrega em runtime)');
}

console.log('\n' + '='.repeat(50));
console.log('VERIFICAÇÃO CONCLUÍDA');
console.log('='.repeat(50));
