# 💬 Guia do Chat com IA - Seleção em Cascata

## 🎯 **Visão Geral**

O chat foi atualizado para usar **seleção em cascata** com dados reais do banco de dados SQL Server.

---

## 🔄 **Fluxo de Interação**

### **1. Nome do Cliente**
```
🤖 AutoParts AI: Olá! Eu sou a AutoParts AI. Para te ajudar, qual é o seu nome?
👤 Cliente: [Digite o nome]
```

### **2. Seleção de Grupo Empresarial**
```
🤖 AutoParts AI: Perfeito, João! Agora selecione o grupo empresarial do seu veículo:

[Botão: Stellantis - 15 fabricantes, 120 modelos]
[Botão: Volkswagen Group - 11 fabricantes, 85 modelos]
[Botão: General Motors - 4 fabricantes, 45 modelos]
...
```

### **3. Seleção de Fabricante**
```
🤖 AutoParts AI: Ótimo! O grupo Stellantis possui 15 fabricantes. Qual é o fabricante do seu veículo?

[Botão: Jeep - Estados Unidos - 8 modelos]
[Botão: Fiat - Itália - 12 modelos]
[Botão: Peugeot - França - 10 modelos]
...
```

### **4. Seleção de Modelo**
```
🤖 AutoParts AI: Perfeito! Qual modelo de Jeep você possui?

[Botão: Compass - SUV - 2017 - Atual]
[Botão: Renegade - SUV - 2015 - Atual]
[Botão: Commander - SUV - 2022 - Atual]
...
```

### **5. Categoria de Peças**
```
🤖 AutoParts AI: Excelente, João! Você possui um Jeep Compass do grupo Stellantis.

Agora, em qual categoria de peças você está interessado?

• Motor
• Suspensão
• Freios
• Transmissão
• Elétrica
• Carroceria
• Filtros
• Iluminação
• Arrefecimento
• Escapamento

👤 Cliente: [Digite a categoria]
```

### **6. Resumo**
```
🤖 AutoParts AI: Anotado! Resumo:

👤 Cliente: João
🏢 Grupo: Stellantis
🏭 Fabricante: Jeep
🚗 Modelo: Compass
📦 Categoria: Freios

Em breve mostrarei as peças compatíveis com seu veículo!
```

---

## ✨ **Recursos Implementados**

### **1. Seleção em Cascata**
- ✅ Dados carregados dinamicamente das APIs
- ✅ Botões interativos para seleção
- ✅ Informações adicionais (país, total de modelos, período)

### **2. Loading States**
- ✅ Indicador de carregamento (3 bolinhas animadas)
- ✅ Botões desabilitados durante carregamento
- ✅ Input desabilitado quando não aplicável

### **3. UX Melhorada**
- ✅ Auto-scroll para última mensagem
- ✅ Placeholders dinâmicos
- ✅ Feedback visual em hover
- ✅ Mensagens com quebra de linha

### **4. Validação**
- ✅ Input obrigatório para nome
- ✅ Seleção obrigatória para grupo/fabricante/modelo
- ✅ Tratamento de erros de API

---

## 🔌 **APIs Utilizadas**

| API | Quando é chamada |
|-----|------------------|
| `GET /api/grupos` | Após cliente informar o nome |
| `GET /api/fabricantes/[grupoId]` | Após selecionar grupo |
| `GET /api/modelos/[fabricanteId]` | Após selecionar fabricante |

---

## 🎨 **Componentes Visuais**

### **Mensagens do Assistente**
- Fundo azul claro (`bg-blue-50`)
- Borda azul (`border-blue-100`)
- Alinhado à esquerda
- Canto superior esquerdo arredondado

### **Mensagens do Usuário**
- Fundo preto (`bg-gray-900`)
- Texto branco
- Alinhado à direita
- Canto superior direito arredondado

### **Botões de Seleção**
- Fundo branco com borda azul
- Hover: borda azul escuro + fundo azul claro
- Desabilitado: opacidade 50%
- Informações em duas linhas (label + sublabel)

---

## 🧪 **Como Testar**

### **1. Instalar dependências:**
```bash
cd C:\TMP\ai-builder-hackathon-2025-alanalvesdeoliveira
npm install
```

### **2. Iniciar o servidor:**
```bash
npm run dev
```

### **3. Acessar o chat:**
```
http://localhost:3000/chat
```

### **4. Fluxo de teste:**
1. Digite seu nome: "João"
2. Clique em "Stellantis"
3. Clique em "Jeep"
4. Clique em "Compass"
5. Digite "Freios"

---

## 🐛 **Troubleshooting**

### **Erro: "Erro ao carregar grupos"**
- Verifique se o servidor Next.js está rodando
- Verifique se o SQL Server está ativo
- Teste a API diretamente: http://localhost:3000/api/grupos

### **Botões não aparecem**
- Verifique o console do navegador (F12)
- Confirme que as APIs retornam dados
- Verifique se há dados no banco de dados

### **Loading infinito**
- Verifique a conexão com o banco de dados
- Veja os logs do servidor Next.js
- Teste as credenciais em `lib/db.ts`

---

## 🚀 **Próximos Passos**

1. ✅ **Integrar com IA real** (OpenAI/Claude) para respostas mais naturais
2. ✅ **Buscar peças compatíveis** usando `AIHT_sp_BuscarPecasPorVeiculo`
3. ✅ **Exibir catálogo de peças** com preços e estoque
4. ✅ **Adicionar ao carrinho** e finalizar compra
5. ✅ **Histórico de conversas** (salvar no localStorage ou banco)

---

## 📝 **Código-Fonte**

O componente de chat está em:
```
app/chat/page.tsx
```

Principais funções:
- `loadGrupos()` - Carrega grupos empresariais
- `loadFabricantes()` - Carrega fabricantes de um grupo
- `loadModelos()` - Carrega modelos de um fabricante
- `handleOptionClick()` - Processa clique em botão de seleção
- `handleSubmit()` - Processa envio de texto

---

**Chat atualizado e pronto para uso! 🎉**
