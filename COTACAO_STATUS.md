# 💰 Status do Sistema de Cotação - AutoParts AI

**Data da Análise:** 25/10/2025  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 📊 Análise Completa Realizada

### ✅ Componentes Implementados

#### **1. Backend - APIs REST**

##### **API de Geração de Cotação**
- **Endpoint:** `POST /api/gerar-cotacao`
- **Arquivo:** `app/api/gerar-cotacao/route.ts`
- **Funcionalidades:**
  - ✅ Detecta intenção de cotação via palavras-chave
  - ✅ Busca peças identificadas na conversa
  - ✅ Gera prompt personalizado para Gemini
  - ✅ Retorna cotação com preços e links
  - ✅ Registra log da chamada à IA

##### **API de Listagem de Peças**
- **Endpoint:** `GET /api/pecas-cotacao/[conversaId]`
- **Arquivo:** `app/api/pecas-cotacao/[conversaId]/route.ts`
- **Funcionalidades:**
  - ✅ Lista peças identificadas por conversa
  - ✅ Usa stored procedure `AIHT_sp_ListarPecasParaCotacao`

##### **API de Resumo de Cotação**
- **Endpoint:** `GET /api/resumo-cotacao/[conversaId]`
- **Arquivo:** `app/api/resumo-cotacao/[conversaId]/route.ts`
- **Funcionalidades:**
  - ✅ Retorna resumo completo da conversa
  - ✅ Inclui informações do veículo
  - ✅ Lista problemas e peças identificadas
  - ✅ Usa stored procedure `AIHT_sp_ResumoCotacao`

---

#### **2. Frontend - Interface de Chat**

##### **Integração no Chat**
- **Arquivo:** `app/chat/page.tsx`
- **Linhas:** 214-233
- **Funcionalidades:**
  - ✅ Detecta automaticamente intenção de cotação
  - ✅ Chama API de cotação após identificar peças
  - ✅ Exibe resposta de cotação no chat
  - ✅ Logs de debug no console

**Fluxo Atual:**
```
1. Usuário envia mensagem
2. API identifica peças
3. Sistema verifica intenção de cotação
4. Se detectado, gera cotação automática
5. Exibe cotação no chat
```

---

#### **3. Banco de Dados - SQL Server**

##### **Tabela de Palavras-Chave**
- **Nome:** `AIHT_PalavrasCotacao`
- **Script:** `SQL/23_tabela_palavras_cotacao.sql`
- **Campos:**
  - `Id` - Identificador único
  - `Palavra` - Palavra ou expressão
  - `Tipo` - 'Palavra' ou 'Expressao'
  - `Ativo` - Flag de ativação
  - `DataCriacao` - Data de cadastro

**Palavras Cadastradas (62+):**
- Simples: cotação, preço, valor, comprar, loja, site, link
- Expressões: "quanto custa", "quero comprar", "onde comprar", "fazer orçamento"

##### **Stored Procedures de Cotação**

**1. AIHT_sp_VerificarIntencaoCotacao**
- **Script:** `SQL/24_atualizar_sp_verificar_cotacao.sql`
- **Função:** Detecta se mensagem tem intenção de cotação
- **Retorna:** 
  - `IntencaoCotacao` (BIT)
  - `PalavrasEncontradas` (VARCHAR)
- **Características:**
  - ✅ Case-insensitive (usa UPPER)
  - ✅ Busca por palavras e expressões
  - ✅ Retorna palavras encontradas

**2. AIHT_sp_ListarPecasParaCotacao**
- **Script:** `SQL/21_sp_cotacao_com_marcas.sql`
- **Função:** Lista peças identificadas com informações completas
- **Retorna:**
  - Dados da peça (nome, código, categoria, prioridade)
  - Dados do problema
  - Dados do veículo (marca, modelo, grupo)
  - Dados do cliente

**3. AIHT_sp_ResumoCotacao**
- **Script:** `SQL/21_sp_cotacao_com_marcas.sql`
- **Função:** Retorna resumo completo para cotação
- **Retorna 3 recordsets:**
  1. Informações da conversa e veículo
  2. Problemas identificados
  3. Peças identificadas

**4. AIHT_sp_ListarPalavrasCotacao**
- **Script:** `SQL/23_tabela_palavras_cotacao.sql`
- **Função:** Lista todas as palavras-chave cadastradas

**5. AIHT_sp_AdicionarPalavraCotacao**
- **Script:** `SQL/23_tabela_palavras_cotacao.sql`
- **Função:** Adiciona nova palavra-chave ao sistema

---

## 🎯 Funcionalidades Implementadas

### ✅ Detecção Automática
- Sistema detecta automaticamente quando cliente quer cotação
- Usa 62+ palavras e expressões cadastradas
- Funciona com qualquer combinação de maiúsculas/minúsculas

### ✅ Geração Inteligente
- Gemini Pro gera cotação personalizada
- Inclui faixa de preço estimada
- Sugere links de e-commerce (Mercado Livre, OLX)
- Recomenda lojas físicas (AutoZone, Nakata)
- Dicas de compra (original vs paralela)

### ✅ Contexto Completo
- Cotação considera o veículo específico
- Inclui informações do problema
- Lista todas as peças necessárias
- Prioriza peças por importância

---

## 🚀 Próximas Melhorias Sugeridas

### 📱 **1. Interface Visual de Cotação**

**Problema Atual:**
- Cotação aparece apenas como texto no chat
- Não há visualização estruturada
- Difícil comparar múltiplas peças

**Solução Proposta:**
- Criar componente visual de cotação
- Card para cada peça com:
  - Nome e código
  - Faixa de preço
  - Botões de ação (links externos)
  - Status (disponível/indisponível)

**Arquivos a Criar:**
```
app/components/CotacaoCard.tsx
app/components/CotacaoList.tsx
app/components/CotacaoSummary.tsx
```

---

### 💾 **2. Salvar Cotações no Banco**

**Problema Atual:**
- Cotações não são salvas
- Não há histórico de preços
- Impossível comparar cotações antigas

**Solução Proposta:**
- Criar tabela `AIHT_Cotacoes`
- Criar tabela `AIHT_ItensCotacao`
- Salvar cada cotação gerada
- Permitir consultar histórico

**Scripts SQL a Criar:**
```sql
-- Tabela de cotações
CREATE TABLE AIHT_Cotacoes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ConversaId INT NOT NULL,
    DataCotacao DATETIME NOT NULL DEFAULT GETDATE(),
    ValorTotal DECIMAL(10,2),
    Status VARCHAR(20) -- 'Pendente', 'Aprovada', 'Rejeitada'
);

-- Tabela de itens da cotação
CREATE TABLE AIHT_ItensCotacao (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CotacaoId INT NOT NULL,
    PecaId INT NOT NULL,
    PrecoMinimo DECIMAL(10,2),
    PrecoMaximo DECIMAL(10,2),
    LinkCompra VARCHAR(500),
    Fornecedor VARCHAR(200)
);
```

---

### 🔗 **3. Integração com APIs de E-commerce**

**Objetivo:**
- Buscar preços reais em tempo real
- Integrar com Mercado Livre API
- Integrar com outras plataformas

**APIs Sugeridas:**
- Mercado Livre API (oficial)
- Google Shopping API
- APIs de distribuidoras de peças

**Benefícios:**
- Preços atualizados
- Links diretos para compra
- Comparação automática

---

### 📊 **4. Dashboard de Cotações**

**Funcionalidades:**
- Visualizar todas as cotações
- Filtrar por data, cliente, veículo
- Estatísticas (ticket médio, peças mais cotadas)
- Exportar para PDF/Excel

**Página a Criar:**
```
app/cotacoes/page.tsx
app/cotacoes/[id]/page.tsx
```

---

### 🤖 **5. Melhorias na IA**

**Prompt Aprimorado:**
- Incluir informações de compatibilidade
- Sugerir peças alternativas
- Alertar sobre peças falsificadas
- Indicar tempo de entrega estimado

**Exemplo de Prompt Melhorado:**
```typescript
const promptCotacao = `
Você é um especialista em peças automotivas e cotações.

VEÍCULO: ${marca} ${modelo}
PEÇAS SOLICITADAS:
${pecas.map(p => `- ${p.NomePeca} (${p.CodigoPeca})`).join('\n')}

Para cada peça, forneça:
1. COMPATIBILIDADE
   - Confirme compatibilidade com o veículo
   - Liste modelos alternativos compatíveis

2. PREÇOS (em R$)
   - Original (montadora): R$ XXX - R$ XXX
   - Paralela (qualidade): R$ XXX - R$ XXX
   - Usada (se aplicável): R$ XXX - R$ XXX

3. ONDE COMPRAR
   - Link Mercado Livre: [URL]
   - Link OLX: [URL]
   - Lojas físicas próximas

4. DICAS IMPORTANTES
   - Cuidados na compra
   - Como identificar falsificações
   - Garantia recomendada

5. INSTALAÇÃO
   - Complexidade: Fácil/Média/Difícil
   - Tempo estimado
   - Necessita mecânico?

Seja específico e útil!
`;
```

---

### 📧 **6. Notificações e Alertas**

**Funcionalidades:**
- Email com resumo da cotação
- Alerta de variação de preço
- Notificação quando peça ficar disponível
- Lembrete de validade da cotação

---

### 🔐 **7. Sistema de Aprovação**

**Fluxo:**
1. Cliente recebe cotação
2. Pode aprovar/rejeitar cada item
3. Sistema gera pedido
4. Envia para fornecedor

**Tabelas Necessárias:**
```sql
CREATE TABLE AIHT_Pedidos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CotacaoId INT NOT NULL,
    Status VARCHAR(20),
    DataPedido DATETIME,
    DataEntrega DATETIME
);
```

---

## 🛠️ Implementação Imediata Recomendada

### **Fase 1: Melhorar Visualização (1-2 dias)**
1. Criar componente `CotacaoCard.tsx`
2. Estilizar com Tailwind CSS
3. Adicionar botões de ação
4. Integrar no chat

### **Fase 2: Persistência (1 dia)**
1. Criar tabelas de cotação
2. Criar stored procedures
3. Salvar cotações geradas
4. API de histórico

### **Fase 3: Dashboard (2-3 dias)**
1. Página de listagem
2. Filtros e busca
3. Detalhes da cotação
4. Exportação PDF

### **Fase 4: Integrações (3-5 dias)**
1. Integrar Mercado Livre API
2. Buscar preços reais
3. Atualizar prompt da IA
4. Testes e ajustes

---

## 📝 Scripts SQL Prontos para Executar

### **Ordem de Execução:**
```bash
# Se ainda não executados:
1. SQL/23_tabela_palavras_cotacao.sql
2. SQL/24_atualizar_sp_verificar_cotacao.sql
3. SQL/21_sp_cotacao_com_marcas.sql

# Diagnóstico:
4. SQL/25_verificar_sistema_cotacao.sql
```

---

## 🎨 Exemplo de Interface Proposta

### **Card de Cotação:**
```
┌─────────────────────────────────────────────┐
│ 🔧 Pastilha de Freio Dianteira              │
│ Código: PF-1234-JC                          │
├─────────────────────────────────────────────┤
│ 💰 Preços Encontrados:                      │
│                                             │
│ Original (Bosch)    R$ 180,00 - R$ 220,00  │
│ Paralela (TRW)      R$ 120,00 - R$ 150,00  │
│                                             │
│ [🛒 Mercado Livre] [🔍 OLX] [📍 Lojas]     │
├─────────────────────────────────────────────┤
│ ⚠️ Dica: Prefira original para segurança   │
│ ⏱️ Instalação: 30-45 min (Mecânico)        │
└─────────────────────────────────────────────┘
```

---

## ✅ Checklist de Validação

Antes de continuar o desenvolvimento, validar:

- [ ] SQL Server está rodando
- [ ] Tabela `AIHT_PalavrasCotacao` existe
- [ ] Stored procedures de cotação criadas
- [ ] API `/api/gerar-cotacao` funcionando
- [ ] Detecção de intenção operacional
- [ ] Chat exibe cotações corretamente
- [ ] Logs de IA sendo salvos

---

## 🎯 Objetivo Final

**Sistema Completo de Cotação que:**
1. ✅ Detecta automaticamente intenção
2. ✅ Gera cotação inteligente via IA
3. 🔄 Exibe de forma visual e organizada
4. 🔄 Salva histórico no banco
5. 🔄 Permite comparar preços
6. 🔄 Integra com e-commerce real
7. 🔄 Gera pedidos automaticamente
8. 🔄 Envia notificações

**Status Atual:** 40% completo  
**Próximo Marco:** Interface visual de cotação

---

**Desenvolvido com ❤️ por Alan Alves de Oliveira**  
**AI Builder Hackathon 2025**
