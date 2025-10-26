/**
 * Script para reprocessar logs de cotação que foram finalizados incorretamente
 * Autor: Alan Alves de Oliveira
 * Data: 26/10/2025
 */

const fs = require('fs');
const path = require('path');
const sql = require('mssql');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Carregar .env.local manualmente
function loadEnv() {
  const envPath = path.join(__dirname, '.env.local');
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    envContent.split('\n').forEach(line => {
      const match = line.match(/^([^=:#]+)=(.*)$/);
      if (match) {
        const key = match[1].trim();
        const value = match[2].trim();
        process.env[key] = value;
      }
    });
  }
}

loadEnv();

// Configuração do banco
const dbConfig = {
  server: 'localhost\\ALYASQLEXPRESS',
  database: 'AI_Builder_Hackthon',
  user: 'AI_Hackthon',
  password: '41@H4ckth0n',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true
  }
};

// Configuração da IA
if (!process.env.GEMINI_API_KEY) {
  console.error('❌ GEMINI_API_KEY não encontrada!');
  console.error('   Verifique se o arquivo .env.local existe e contém a chave.');
  process.exit(1);
}

console.log('🔑 API Key carregada:', process.env.GEMINI_API_KEY.substring(0, 10) + '...');
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function reprocessarCotacoes() {
  let pool;
  
  try {
    console.log('========================================');
    console.log('REPROCESSAR COTAÇÕES INCORRETAS');
    console.log('========================================\n');

    // Conectar ao banco
    console.log('📊 Conectando ao banco de dados...');
    pool = await sql.connect(dbConfig);
    console.log('✅ Conectado!\n');

    // 1. Buscar logs incorretos
    console.log('🔍 Buscando logs finalizados incorretamente...');
    const logsIncorretos = await pool.request().query(`
      SELECT 
        l.Id AS LogId,
        l.ConversaId,
        l.MensagemCliente,
        l.TipoChamada,
        c.NomeCliente,
        m.Nome AS ModeloVeiculo,
        marc.Nome AS MarcaVeiculo
      FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
      INNER JOIN [AI_Builder_Hackthon].[dbo].[AIHT_Conversas] c ON l.ConversaId = c.Id
      LEFT JOIN [AI_Builder_Hackthon].[dbo].[AIHT_Modelos] m ON c.ModeloId = m.Id
      LEFT JOIN [AI_Builder_Hackthon].[dbo].[AIHT_Marcas] marc ON m.MarcaId = marc.Id
      WHERE UPPER(LTRIM(RTRIM(l.MensagemCliente))) IN (
        SELECT [Palavra] 
        FROM [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] 
        WHERE Ativo = 1
      )
      AND l.PromptEnviado LIKE 'Você está finalizando%'
      ORDER BY l.ConversaId, l.DataChamada
    `);

    const logs = logsIncorretos.recordset;
    console.log(`   Encontrados: ${logs.length} logs para reprocessar\n`);

    if (logs.length === 0) {
      console.log('✅ Nenhum log para reprocessar!');
      return;
    }

    // 2. Buscar prompt de cotação
    console.log('📝 Buscando prompt de cotação...');
    const promptResult = await pool.request()
      .input('Contexto', 'cotacao')
      .execute('AIHT_sp_ObterPromptPorContexto');
    
    const promptTemplate = promptResult.recordset[0]?.ConteudoPrompt;
    
    if (!promptTemplate) {
      console.error('❌ Prompt de cotação não encontrado!');
      return;
    }
    console.log('✅ Prompt encontrado!\n');

    // 3. Processar cada conversa
    const conversasProcessadas = new Set();
    let totalCotacoesGeradas = 0;

    for (const log of logs) {
      // Evitar processar a mesma conversa múltiplas vezes
      if (conversasProcessadas.has(log.ConversaId)) {
        console.log(`⏭️  Conversa ${log.ConversaId} já processada, pulando...`);
        continue;
      }

      console.log(`\n${'='.repeat(60)}`);
      console.log(`📋 Processando Conversa ${log.ConversaId}`);
      console.log(`   Cliente: ${log.NomeCliente}`);
      console.log(`   Veículo: ${log.MarcaVeiculo} ${log.ModeloVeiculo}`);
      console.log(`   Mensagem: "${log.MensagemCliente}"`);
      console.log(`${'='.repeat(60)}\n`);

      try {
        // 3.1. Buscar peças da conversa
        console.log('   🔍 Buscando peças identificadas...');
        const pecasResult = await pool.request()
          .input('ConversaId', log.ConversaId)
          .execute('AIHT_sp_ListarPecasParaCotacao');
        
        const pecas = pecasResult.recordset;
        
        if (pecas.length === 0) {
          console.log('   ⚠️  Nenhuma peça encontrada para esta conversa');
          conversasProcessadas.add(log.ConversaId);
          continue;
        }
        
        console.log(`   ✅ ${pecas.length} peças encontradas`);

        // 3.2. Montar prompt
        const listaPecas = pecas.map((p, i) => 
          `${i + 1}. ${p.NomePeca} - ${p.CodigoPeca || 'Sem código'}`
        ).join('\n');

        const promptCotacao = promptTemplate
          .replace(/\{\{fabricante_veiculo\}\}/g, log.MarcaVeiculo || 'Veículo')
          .replace(/\{\{modelo_veiculo\}\}/g, log.ModeloVeiculo || '')
          .replace(/\{\{lista_pecas\}\}/g, listaPecas);

        // 3.3. Chamar IA
        console.log('   🤖 Gerando cotação com IA...');
        const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
        const startTime = Date.now();
        const result = await model.generateContent(promptCotacao);
        const response = await result.response;
        const cotacao = response.text();
        const tempoResposta = Date.now() - startTime;
        
        console.log(`   ✅ Cotação gerada em ${tempoResposta}ms`);
        console.log(`   📏 Tamanho da resposta: ${cotacao.length} caracteres`);

        // 3.4. ATUALIZAR log existente
        console.log('   💾 Atualizando log existente...');
        await pool.request()
          .input('LogId', log.LogId)
          .input('PromptEnviado', promptCotacao)
          .input('RespostaRecebida', cotacao)
          .input('TempoResposta', tempoResposta)
          .input('TipoChamada', 'gerar-cotacao')
          .query(`
            UPDATE [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA]
            SET 
              TipoChamada = @TipoChamada,
              PromptEnviado = @PromptEnviado,
              RespostaRecebida = @RespostaRecebida,
              TempoResposta = @TempoResposta,
              Sucesso = 1,
              MensagemErro = NULL,
              ModeloIA = 'gemini-pro',
              DataChamada = GETDATE()
            WHERE Id = @LogId
          `);
        console.log('   ✅ Log atualizado!');

        // 3.5. Parsear e salvar cotações
        console.log('   📦 Parseando e salvando cotações...');
        const cotacoesSalvas = await parsearESalvarCotacoes(cotacao, pecas, log.ConversaId, pool);
        console.log(`   ✅ ${cotacoesSalvas} cotações salvas no banco`);
        
        totalCotacoesGeradas += cotacoesSalvas;
        conversasProcessadas.add(log.ConversaId);

      } catch (error) {
        console.error(`   ❌ Erro ao processar conversa ${log.ConversaId}:`, error.message);
      }
    }

    console.log('\n========================================');
    console.log('REPROCESSAMENTO CONCLUÍDO');
    console.log('========================================');
    console.log(`✅ Conversas processadas: ${conversasProcessadas.size}`);
    console.log(`✅ Cotações geradas: ${totalCotacoesGeradas}`);
    console.log('========================================\n');

  } catch (error) {
    console.error('❌ ERRO CRÍTICO:', error);
  } finally {
    if (pool) {
      await pool.close();
    }
  }
}

// Função para parsear e salvar cotações (simplificada)
async function parsearESalvarCotacoes(respostaIA, pecas, conversaId, pool) {
  let totalSalvas = 0;
  const linhas = respostaIA.split('\n');
  
  let nomePecaAtual = null;
  let cotacaoAtual = {};

  for (const linha of linhas) {
    const linhaTrim = linha.trim();

    // Detectar início de seção de peça
    const secaoPecaMatch = linhaTrim.match(/^###\s+\d+\.\s+(.+)/);
    if (secaoPecaMatch) {
      // Salvar cotação anterior
      if (cotacaoAtual.nomePeca && cotacaoAtual.tipoCotacao) {
        await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
        totalSalvas++;
      }
      
      nomePecaAtual = secaoPecaMatch[1].replace(/\*/g, '').trim();
      cotacaoAtual = { nomePeca: nomePecaAtual };
      continue;
    }

    if (!nomePecaAtual) continue;

    // Detectar tipo
    if (linhaTrim.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*e-Commerce/i)) {
      if (cotacaoAtual.nomePeca && cotacaoAtual.tipoCotacao) {
        await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
        totalSalvas++;
      }
      cotacaoAtual = { nomePeca: nomePecaAtual, tipoCotacao: 'e-Commerce' };
    } else if (linhaTrim.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*Loja Física/i)) {
      if (cotacaoAtual.nomePeca && cotacaoAtual.tipoCotacao) {
        await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
        totalSalvas++;
      }
      cotacaoAtual = { nomePeca: nomePecaAtual, tipoCotacao: 'Loja Física' };
    }

    // Extrair campos
    const linkMatch = linhaTrim.match(/^\?\?\s*\*\*\s*Link:\s*\*\*\s*(.+)/i);
    if (linkMatch) cotacaoAtual.link = linkMatch[1].trim();

    const enderecoMatch = linhaTrim.match(/^\?\?\s*\*\*\s*Endereço:\s*\*\*\s*(.+)/i);
    if (enderecoMatch) cotacaoAtual.endereco = enderecoMatch[1].trim();

    const precoMatch = linhaTrim.match(/^\?\?\s*\*\*\s*Preço:\s*\*\*\s*(.+)/i);
    if (precoMatch) {
      const precoTexto = precoMatch[1].trim();
      const precos = precoTexto.match(/R\$\s*([\d.,]+)/g);
      if (precos && precos.length >= 2) {
        cotacaoAtual.precoMinimo = parseFloat(precos[0].replace(/[^\d,]/g, '').replace(',', '.'));
        cotacaoAtual.precoMaximo = parseFloat(precos[1].replace(/[^\d,]/g, '').replace(',', '.'));
      } else if (precos && precos.length === 1) {
        const preco = parseFloat(precos[0].replace(/[^\d,]/g, '').replace(',', '.'));
        cotacaoAtual.preco = preco;
      }
    }

    const condicoesMatch = linhaTrim.match(/^\?\?\s*\*\*\s*Condições de Pagamento:\s*\*\*\s*(.+)/i);
    if (condicoesMatch) cotacaoAtual.condicoesPagamento = condicoesMatch[1].trim();

    const obsMatch = linhaTrim.match(/^\?\s*\*\*\s*Observações:\s*\*\*\s*(.+)/i);
    if (obsMatch) cotacaoAtual.observacoes = obsMatch[1].trim();
  }

  // Salvar última cotação
  if (cotacaoAtual.nomePeca && cotacaoAtual.tipoCotacao) {
    await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
    totalSalvas++;
  }

  return totalSalvas;
}

async function salvarCotacao(cotacao, pecas, conversaId, pool) {
  // Encontrar peça correspondente
  const pecaEncontrada = pecas.find(p => {
    const nomeBanco = p.NomePeca.toLowerCase();
    const nomeResposta = cotacao.nomePeca.toLowerCase();
    return nomeBanco.includes(nomeResposta) || 
           nomeResposta.includes(nomeBanco) ||
           nomeBanco.split(' ').some(palavra => 
             palavra.length > 3 && nomeResposta.includes(palavra)
           );
  });

  const pecaId = pecaEncontrada?.Id || null;

  await pool.request()
    .input('ConversaId', conversaId)
    .input('PecaIdentificadaId', pecaId)
    .input('NomePeca', cotacao.nomePeca)
    .input('TipoCotacao', cotacao.tipoCotacao)
    .input('Link', cotacao.link || cotacao.endereco || null)
    .input('Preco', cotacao.preco || null)
    .input('PrecoMinimo', cotacao.precoMinimo || null)
    .input('PrecoMaximo', cotacao.precoMaximo || null)
    .input('CondicoesPagamento', cotacao.condicoesPagamento || null)
    .input('Observacoes', cotacao.observacoes || null)
    .execute('AIHT_sp_SalvarCotacao');
}

// Executar
reprocessarCotacoes()
  .then(() => {
    console.log('✅ Script finalizado com sucesso!');
    process.exit(0);
  })
  .catch(error => {
    console.error('❌ Erro fatal:', error);
    process.exit(1);
  });
