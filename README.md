# 🚗 AutoParts AI - AI Builder Hackathon 2025

## 🎯 Sobre o Projeto

**E-Commerce Inteligente de Peças Automotivas com IA Conversacional**

Solução inovadora desenvolvida para o AI Builder Hackathon 2025 que revoluciona a experiência de compra de peças automotivas através de um assistente virtual inteligente. O sistema utiliza **Google Gemini Pro** para fornecer diagnósticos técnicos precisos, identificar peças necessárias e recomendar soluções personalizadas para cada veículo.

### 🚗 Foco da Aplicação

**E-Commerce de Peças Automotivas Multimarcas**

A aplicação é especializada em peças automotivas para os seguintes tipos de veículos:
- ✅ **Sedans**
- ✅ **Hatchbacks**
- ✅ **Pick-ups** (pequenas e médias)
- ✅ **SUVs**

**Importante:** A plataforma **não** atende veículos de carga, motocicletas e ciclomotores.

### 🧠 Objetivo
Criar uma aplicação web inovadora que utiliza **Chat com IA** para revolucionar a experiência de compra de peças automotivas. O sistema interage de forma natural com o cliente, coletando informações sobre seu veículo e recomendando as peças e acessórios ideais com precisão e eficiência.

### 💬 Como Funciona

#### **Fluxo de Atendimento:**
1. **Coleta de Informações** - Cliente informa nome, grupo empresarial, fabricante e modelo do veículo
2. **Chat Inteligente** - Cliente descreve o problema ou peça desejada
3. **Análise por IA** - Google Gemini Pro analisa o problema e identifica causas
4. **Diagnóstico Técnico** - IA fornece explicação detalhada do problema
5. **Identificação de Peças** - Sistema identifica automaticamente as peças necessárias
6. **Detecção de Cotação** - Sistema detecta automaticamente quando cliente quer cotação
7. **Geração de Cotação** - IA gera cotação com preços estimados e links de compra
8. **Visualização Compacta** - Interface otimizada mostra até 12 peças sem scroll
9. **Registro no Banco** - Problemas e peças são salvos para consulta futura
10. **Recomendações** - IA sugere próximos passos e cuidados

### 🌟 Funcionalidades Implementadas

#### **🤖 Inteligência Artificial**
- ✅ **Google Gemini Pro** - Modelo de IA para análise e diagnóstico
- ✅ **Prompts Dinâmicos** - Armazenados no banco de dados, editáveis
- ✅ **Substituição de Variáveis** - Personalização automática (nome, veículo, etc)
- ✅ **Identificação Automática** - Extração de problemas e peças da conversa
- ✅ **Respostas Estruturadas** - Formato técnico com emojis e formatação

#### **💬 Sistema de Chat**
- ✅ **Interface Moderna** - Design responsivo com Tailwind CSS
- ✅ **Formulário Lateral** - Seleção de veículo em cascata
- ✅ **Histórico de Mensagens** - Todas as interações salvas
- ✅ **Feedback Visual** - Loading states e indicadores
- ✅ **Scroll Automático** - Acompanha novas mensagens
- ✅ **Detecção Automática de Cotação** - Identifica quando cliente quer preços

#### **💰 Sistema de Cotação Inteligente**
- ✅ **Detecção por Palavras-Chave** - 62+ palavras e expressões cadastradas
- ✅ **Geração Automática** - IA cria cotação com preços e links
- ✅ **Interface Compacta** - Visualização otimizada sem scroll
- ✅ **Cards Responsivos** - Grid adaptativo (1/2/3 colunas)
- ✅ **Preços Estimados** - Faixa de valores por categoria de peça
- ✅ **Links de E-commerce** - Mercado Livre, OLX e Google
- ✅ **Página Dedicada** - `/cotacao/[id]` para visualização completa
- ✅ **Exportação** - Imprimir ou copiar lista de peças

#### **📊 Banco de Dados**
- ✅ **15 Grupos Empresariais** - Stellantis, GM, Ford, etc
- ✅ **Múltiplos Fabricantes** - Jeep, Chevrolet, Fiat, etc
- ✅ **Diversos Modelos** - Compass, Onix, Ranger, etc
- ✅ **Sistema de Prompts** - Armazenamento de instruções para IA
- ✅ **Rastreamento de Conversas** - Histórico completo
- ✅ **Identificação de Problemas** - Registro de diagnósticos
- ✅ **Catálogo de Peças** - Peças identificadas por conversa
- ✅ **Palavras-Chave de Cotação** - 62+ termos para detecção automática
- ✅ **Log de Chamadas IA** - Auditoria completa de todas as interações

#### **🔧 APIs Implementadas**
- ✅ `GET /api/grupos` - Lista grupos empresariais
- ✅ `GET /api/fabricantes/[grupoId]` - Lista fabricantes por grupo
- ✅ `GET /api/modelos/[fabricanteId]` - Lista modelos por fabricante
- ✅ `GET /api/prompts/[contexto]` - Busca prompt por contexto
- ✅ `POST /api/conversas` - Cria nova conversa
- ✅ `POST /api/identificar-pecas` - Identifica problemas e peças via IA
- ✅ `POST /api/chat` - Envia mensagem para IA
- ✅ `POST /api/gerar-cotacao` - Gera cotação automática com IA
- ✅ `GET /api/pecas-cotacao/[conversaId]` - Lista peças para cotação
- ✅ `GET /api/resumo-cotacao/[conversaId]` - Resumo completo da conversa
- ✅ `GET /api/test-env` - Testa variáveis de ambiente

#### **🗄️ Stored Procedures**
- ✅ `AIHT_sp_ListarGruposEmpresariais` - Lista grupos com contadores
- ✅ `AIHT_sp_ListarFabricantesPorGrupo` - Lista fabricantes filtrados
- ✅ `AIHT_sp_ListarModelosPorFabricante` - Lista modelos filtrados
- ✅ `AIHT_sp_BuscarPromptPorContexto` - Busca prompt específico
- ✅ `AIHT_sp_ObterPromptPorContexto` - Obtém prompt ativo
- ✅ `AIHT_sp_CriarConversa` - Registra nova conversa
- ✅ `AIHT_sp_RegistrarProblema` - Registra problema identificado
- ✅ `AIHT_sp_RegistrarPeca` - Registra peça identificada
- ✅ `AIHT_sp_ListarPecasConversa` - Lista peças de uma conversa
- ✅ `AIHT_sp_VerificarIntencaoCotacao` - Detecta intenção de cotação
- ✅ `AIHT_sp_ListarPecasParaCotacao` - Lista peças com dados completos
- ✅ `AIHT_sp_ResumoCotacao` - Resumo completo para cotação
- ✅ `AIHT_sp_ListarPalavrasCotacao` - Lista palavras-chave cadastradas
- ✅ `AIHT_sp_RegistrarChamadaIA` - Registra log de chamada à IA
- ✅ `AIHT_sp_ConsultarLogsIA` - Consulta logs de IA
- ✅ `AIHT_sp_VerDetalhesLogIA` - Detalhes completos de um log

#### **📋 Estrutura de Tabelas**
- ✅ `AIHT_GruposEmpresariais` - Grupos automotivos
- ✅ `AIHT_Marcas` - Fabricantes de veículos
- ✅ `AIHT_Modelos` - Modelos de veículos
- ✅ `AIHT_Prompts` - Instruções para IA
- ✅ `AIHT_Conversas` - Histórico de conversas
- ✅ `AIHT_ProblemasIdentificados` - Problemas diagnosticados
- ✅ `AIHT_PecasIdentificadas` - Peças necessárias
- ✅ `AIHT_PalavrasCotacao` - Palavras-chave para detecção de cotação
- ✅ `AIHT_LogChamadasIA` - Auditoria de chamadas à IA

#### **🎨 Componentes React**
- ✅ `CotacaoCard.tsx` - Card individual de peça (compacto)
- ✅ `CotacaoList.tsx` - Lista de peças com grid responsivo
- ✅ `/cotacao/[conversaId]/page.tsx` - Página dedicada de cotação

#### **🔍 Sistema de Debug**
- ✅ **Logs Completos** - Todas as chamadas à IA registradas
- ✅ **Prompt Enviado** - Visualização do prompt processado
- ✅ **Resposta da IA** - Resposta completa armazenada
- ✅ **Tempo de Resposta** - Medição de performance
- ✅ **Mensagens de Erro** - Rastreamento de falhas
- ✅ **Queries SQL** - Scripts de consulta para análise

## 🚀 Tecnologias

### Frontend
- **[Next.js 15.5.6](https://nextjs.org/)** - Framework React com App Router
- **[TypeScript](https://www.typescriptlang.org/)** - Tipagem estática
- **[Tailwind CSS](https://tailwindcss.com/)** - Framework CSS utilitário
- **[React 19](https://react.dev/)** - Biblioteca para interfaces
- **Componentes Customizados** - CotacaoCard, CotacaoList (otimizados)

### Backend & IA
- **[Google Gemini Pro](https://ai.google.dev/)** - Modelo de IA para análise e diagnóstico
- **[SQL Server Express](https://www.microsoft.com/sql-server)** - Banco de dados relacional
- **[mssql](https://www.npmjs.com/package/mssql)** - Driver Node.js para SQL Server
- **Next.js API Routes** - Backend serverless
- **Stored Procedures** - Lógica de negócio no banco de dados

### Otimizações de UI
- **Grid Responsivo** - 1/2/3 colunas (mobile/tablet/desktop)
- **Design Compacto** - Redução de 50% na altura dos cards
- **Densidade de Informação** - Até 12 peças visíveis sem scroll
- **Performance** - Componentes otimizados para renderização rápida

### Configuração do Banco de Dados
- **Hostname:** `.\ALYASQLEXPRESS`
- **Database:** `AI_Builder_Hackthon`
- **Usuário:** `AI_Hackthon`
- **Password:** `41@H4ckth0n`
- **Prefixo de Tabelas:** `AIHT_`

## 🤖 Processo de Desenvolvimento

Este projeto foi desenvolvido utilizando o conceito de **Vibe Coding**, uma abordagem inovadora de desenvolvimento assistido por IA:

- **IDE**: [Windsurf](https://codeium.com/windsurf) - IDE de próxima geração com IA integrada
- **Modelos de IA utilizados**:
  - **IA-SWE-1** - Modelo especializado em engenharia de software
  - **Claude Sonnet 4.5** - Modelo de linguagem avançado da Anthropic

O Vibe Coding permite um fluxo de desenvolvimento mais intuitivo e produtivo, onde a IA atua como um par de programação inteligente, auxiliando na escrita de código, resolução de problemas e implementação de funcionalidades complexas.

## 🛠️ Como executar o projeto

1. Clone o repositório
2. Instale as dependências:
   ```bash
   npm install
   # ou
   yarn install
   ```
3. Execute o servidor de desenvolvimento:
   ```bash
   npm run dev
   # ou
   yarn dev
   ```
4. Acesse [http://localhost:3000](http://localhost:3000) no seu navegador

## 📦 Scripts disponíveis

- `dev` - Inicia o servidor de desenvolvimento
- `build` - Constrói a aplicação para produção
- `start` - Inicia o servidor de produção
- `lint` - Executa o linter

## 👨‍💻 Desenvolvedor

- **Alan Alves de Oliveira**
- Email: [alan_oliveira76@hotmail.com](mailto:alan_oliveira76@hotmail.com)
- LinkedIn: [Alan Alves de Oliveira](https://www.linkedin.com/in/alan-alves-de-oliveira)

## 🔧 Requisitos Técnicos

- Node.js 18.0.0 ou superior
- npm 9.0.0 ou superior
- Git
- SQL Server Express (com instância ALYASQLEXPRESS configurada)

## 🚀 Primeiros Passos

1. **Clonar o repositório**
   ```bash
   git clone https://github.com/seu-usuario/ai-builder-hackathon-2025.git
   cd ai-builder-hackathon-2025
   ```

2. **Instalar dependências**
   ```bash
   npm install
   # ou
   yarn install
   ```

3. **Configurar o Banco de Dados**
   
   Certifique-se de que o SQL Server Express está instalado e rodando com a instância `ALYASQLEXPRESS`.
   
   Execute os scripts SQL na pasta `/SQL` na seguinte ordem:
   
   **Estrutura Básica:**
   - `01_criar_banco_e_usuario.sql` - Cria banco e usuário
   - `02_criar_tabelas_principais.sql` - Cria tabelas de grupos, marcas e modelos
   - `03_inserir_dados_iniciais.sql` - Insere dados de veículos
   - `04_criar_tabela_prompts.sql` - Cria tabela de prompts
   - `05_grant_permissions.sql` - Concede permissões ao usuário
   
   **Sistema de Conversas:**
   - `06_conversas_CORRIGIDO_FINAL.sql` - Cria tabelas de conversas e peças
   - `12_inserir_prompt_CORRETO.sql` - Insere prompt de identificação
   - `13_criar_tabela_log_ia.sql` - Cria tabela de log de IA
   
   **Sistema de Cotação:**
   - `23_tabela_palavras_cotacao.sql` - Cria tabela de palavras-chave
   - `24_atualizar_sp_verificar_cotacao.sql` - SP de detecção de cotação
   - `21_sp_cotacao_com_marcas.sql` - SPs de listagem para cotação
   
   **Stored Procedures:**
   - Todas as stored procedures são criadas automaticamente pelos scripts acima
   
   **Scripts de Diagnóstico (opcional):**
   - `97_verificar_tabelas_existentes.sql` - Verifica tabelas
   - `98_diagnostico_tabelas.sql` - Diagnóstico completo
   - `99_verificar_stored_procedures.sql` - Verifica SPs

4. **Configurar variáveis de ambiente**
   
   Crie um arquivo `.env.local` na raiz do projeto:
   
   ```env
   # Google Gemini API Key
   # Obtenha sua chave em: https://makersuite.google.com/app/apikey
   GEMINI_API_KEY=sua_chave_api_aqui
   ```
   
   **Importante:** Substitua `sua_chave_api_aqui` pela sua chave do Google Gemini Pro.

5. **Executar o servidor de desenvolvimento**
   ```bash
   npm run dev
   # ou
   yarn dev
   ```
   O aplicativo estará disponível em [http://localhost:3000](http://localhost:3000)

## 📦 Comandos Úteis

- `npm run build` - Constrói a aplicação para produção
- `npm start` - Inicia o servidor de produção
- `npm run lint` - Executa a análise de código
- `npm run test` - Executa os testes

## 🤝 Como Contribuir

1. Faça um Fork do projeto
2. Crie uma Branch para sua Feature
3. Adicione suas mudanças
4. Faça o Commit das suas alterações
5. Faça o Push para a Branch
6. Abra um Pull Request

## 📊 Consultas SQL Úteis

### **Ver Conversas Ativas**
```sql
SELECT 
    c.Id,
    c.NomeCliente,
    g.Nome AS Grupo,
    m.Nome AS Marca,
    mo.Nome AS Modelo,
    c.DataInicio,
    c.Status
FROM AIHT_Conversas c
JOIN AIHT_GruposEmpresariais g ON c.GrupoEmpresarialId = g.Id
JOIN AIHT_Marcas m ON c.MarcaId = m.Id
JOIN AIHT_Modelos mo ON c.ModeloId = mo.Id
ORDER BY c.DataInicio DESC;
```

### **Ver Problemas e Peças Identificadas**
```sql
SELECT 
    c.NomeCliente,
    p.DescricaoProblema,
    pc.NomePeca,
    pc.DataIdentificacao
FROM AIHT_Conversas c
JOIN AIHT_ProblemasIdentificados p ON c.Id = p.ConversaId
JOIN AIHT_PecasIdentificadas pc ON p.Id = pc.ProblemaId
ORDER BY pc.DataIdentificacao DESC;
```

### **Ver Logs de Chamadas à IA**
```sql
-- Últimos 10 logs
EXEC AIHT_sp_ConsultarLogsIA @UltimosN = 10;

-- Ver detalhes de um log específico
EXEC AIHT_sp_VerDetalhesLogIA @LogId = 1;

-- Query direta
SELECT 
    Id,
    LEFT(MensagemCliente, 100) AS Mensagem,
    Sucesso,
    MensagemErro,
    TempoResposta,
    DataChamada
FROM AIHT_LogChamadasIA
ORDER BY DataChamada DESC;
```

### **Estatísticas do Sistema**
```sql
-- Total de conversas
SELECT COUNT(*) AS TotalConversas FROM AIHT_Conversas;

-- Total de problemas identificados
SELECT COUNT(*) AS TotalProblemas FROM AIHT_ProblemasIdentificados;

-- Total de peças identificadas
SELECT COUNT(*) AS TotalPecas FROM AIHT_PecasIdentificadas;

-- Taxa de sucesso da IA
SELECT 
    COUNT(*) AS TotalChamadas,
    SUM(CASE WHEN Sucesso = 1 THEN 1 ELSE 0 END) AS Sucessos,
    CAST(SUM(CASE WHEN Sucesso = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS TaxaSucesso
FROM AIHT_LogChamadasIA;
```

## 🐛 Troubleshooting

### **Erro: "GEMINI_API_KEY não encontrada"**
- Verifique se o arquivo `.env.local` existe na raiz do projeto
- Confirme que a variável está escrita corretamente: `GEMINI_API_KEY`
- Reinicie o servidor após criar/modificar o `.env.local`

### **Erro: "Could not find stored procedure"**
- Execute os scripts SQL na ordem correta
- Verifique se o usuário `AI_Hackthon` tem permissões EXECUTE
- Execute: `GRANT EXECUTE ON SCHEMA::dbo TO AI_Hackthon;`

### **Erro: "Nome de objeto inválido"**
- Verifique se todas as tabelas foram criadas
- Execute os scripts de diagnóstico: `97_verificar_tabelas_existentes.sql`
- Confirme que está no banco correto: `USE AI_Builder_Hackthon;`

### **Chat não responde**
- Verifique os logs no console do servidor
- Consulte a tabela `AIHT_LogChamadasIA` para ver erros
- Teste a API Key: `http://localhost:3000/api/test-env`

## 💰 Sistema de Cotação - Destaque

O **Sistema de Cotação Inteligente** é uma das funcionalidades mais inovadoras do AutoParts AI:

### **Como Usar:**
1. Inicie uma conversa e descreva o problema do veículo
2. A IA identificará automaticamente as peças necessárias
3. Digite palavras como "quanto custa", "preço", "cotação" ou "quero comprar"
4. O sistema detecta automaticamente e gera uma cotação completa
5. Visualize até 12 peças simultaneamente sem scroll
6. Clique nos botões para buscar em Mercado Livre, OLX ou Google

### **Características:**
- ✅ **Detecção Automática** - 62+ palavras-chave cadastradas
- ✅ **Interface Otimizada** - Design compacto (50% menos altura)
- ✅ **Grid Responsivo** - 1/2/3 colunas conforme dispositivo
- ✅ **Preços Estimados** - Faixa de valores por categoria
- ✅ **Links Diretos** - Acesso rápido a e-commerces
- ✅ **Exportação** - Imprimir ou copiar lista

### **Exemplo de Uso:**
```
Você: "Meu freio está fazendo barulho"
IA: [Identifica: Pastilha de Freio, Disco de Freio]

Você: "Quanto custa essas peças?"
IA: [Gera cotação automática com preços e links]
```

### **Acesso Direto:**
- Chat: `http://localhost:3000/chat`
- Cotação: `http://localhost:3000/cotacao/[id]`

## 📝 Licença

Este projeto está sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para obter mais detalhes.

---

**Desenvolvido com ❤️ por Alan Alves de Oliveira para o AI Builder Hackathon 2025**
