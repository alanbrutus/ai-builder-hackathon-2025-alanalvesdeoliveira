# AI Builder Hackathon 2025

## 🎯 Sobre o Projeto

Solução desenvolvida para o desafio do AI Builder Hackathon 2025. Este projeto tem como objetivo demonstrar a aplicação de inteligência artificial na construção de soluções inovadoras, utilizando tecnologias modernas de desenvolvimento web.

### 🚗 Foco da Aplicação

**E-Commerce de Peças Automotivas Multimarcas**

A aplicação é especializada em peças automotivas para os seguintes tipos de veículos:
- **Sedans**
- **Hatchbacks**
- **Pick-ups** (pequenas e médias)
- **SUVs**

**Importante:** A plataforma **não** atende veículos de carga, motocicletas e ciclomotores.

### 🧠 Objetivo
Criar uma aplicação web inovadora que utiliza **Chat com IA** para revolucionar a experiência de compra de peças automotivas. O sistema interage de forma natural com o cliente, coletando informações sobre seu veículo e recomendando as peças e acessórios ideais com precisão e eficiência.

### 💬 Como Funciona
O cliente interage com um assistente virtual inteligente que:
1. **Solicita o nome do cliente** para personalizar o atendimento
2. **Pergunta sobre o fabricante** do veículo (Chevrolet, Ford, VW, etc.)
3. **Identifica o modelo** específico do veículo
4. **Recomenda peças e acessórios** compatíveis com o veículo informado
5. **Auxilia na finalização da compra** de forma conversacional

### 🌟 Recursos Principais
- **Chat com IA** para atendimento personalizado e intuitivo
- Interface moderna e responsiva
- Integração com modelos de IA para recomendação inteligente de peças
- Catálogo multimarcas especializado
- Identificação automática de compatibilidade de peças
- Processamento em tempo real
- Sistema de busca conversacional por veículo e peça
- Experiência de compra guiada por IA

## 🚀 Tecnologias

### Frontend
- [Next.js](https://nextjs.org/) - O framework React para aplicações web
- [TypeScript](https://www.typescriptlang.org/) - Adiciona tipagem estática ao JavaScript
- [Tailwind CSS](https://tailwindcss.com/) - Framework CSS utilitário

### Backend & Banco de Dados
- **SQL Server Express** - Sistema de gerenciamento de banco de dados relacional
- **Configuração do Banco de Dados:**
  - **Hostname:** `.\ALYASQLEXPRESS`
  - **Database:** `AI_Builder_Hackthon`
  - **Usuário:** `AI_Hackthon`
  - **Password:** `41@H4ckth0n`

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
   - `01_create_tables.sql` - Cria as tabelas
   - `02_create_indexes.sql` - Cria os índices
   - `03_seed_data.sql` - Insere dados iniciais
   - `04_create_views.sql` - Cria as views
   - `05_create_procedures.sql` - Cria as stored procedures
   
   Consulte o arquivo `/SQL/README.md` para mais detalhes sobre a estrutura do banco de dados.

4. **Configurar variáveis de ambiente**
   Crie um arquivo `.env.local` na raiz do projeto e adicione as variáveis necessárias:
   ```env
   # Configuração do Banco de Dados
   DB_SERVER=.\\ALYASQLEXPRESS
   DB_DATABASE=AI_Builder_Hackthon
   DB_USER=AI_Hackthon
   DB_PASSWORD=41@H4ckth0n
   
   # String de Conexão Completa
   DATABASE_URL=Server=.\\ALYASQLEXPRESS;Database=AI_Builder_Hackthon;User Id=AI_Hackthon;Password=41@H4ckth0n;TrustServerCertificate=true
   ```

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

## 📝 Licença

Este projeto está sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para obter mais detalhes.
