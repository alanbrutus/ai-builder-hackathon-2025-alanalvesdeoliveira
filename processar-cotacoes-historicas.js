/**
 * Script para processar cotações históricas
 * Busca respostas do banco e executa o parser completo
 */

const sql = require('mssql');

// Configuração do banco (mesma do projeto)
const config = {
  server: 'localhost',
  database: 'AI_Builder_Hackthon',
  user: 'AI_Hackthon',
  password: '41@H4ckth0n',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true,
    useUTC: false,
    instanceName: 'ALYASQLEXPRESS',
  },
  connectionTimeout: 30000,
  requestTimeout: 30000,
};

/**
 * Parser de cotações (copiado do route.ts)
 */
async function parsearESalvarCotacoes(
  respostaIA,
  pecas,
  conversaId,
  pool
) {
  let totalSalvas = 0;

  try {
    console.log('🔍 Iniciando parser de cotações...');
    console.log(`   Total de peças identificadas: ${pecas.length}`);
    console.log(`   📋 Peças identificadas no banco:`);
    pecas.forEach(p => console.log(`      - ${p.NomePeca} (ID: ${p.Id})`));
    
    const linhas = respostaIA.split('\n');
    let cotacaoAtual = {};
    let dentroDeSecaoPeca = false;
    let nomePecaAtual = '';
    let cotacoesEncontradas = 0;

    console.log(`   Total de linhas na resposta: ${linhas.length}`);
    console.log(`\n🔍 INICIANDO ANÁLISE LINHA POR LINHA:\n`);

    for (let i = 0; i < linhas.length; i++) {
      const linha = linhas[i].trim();
      
      // Log detalhado de linhas importantes
      if (linha.includes('##') || linha.includes('??') || linha.includes('Tipo:')) {
        console.log(`   Linha ${i}: "${linha.substring(0, 100)}..."`);
      }

      // Detectar início de seção de peça
      const secaoPecaMatch = linha.match(/^###\s+\d+\.\s+(.+)/) ||
                             linha.match(/^####\s+\*\*\d+\.\s+(.+)/) ||
                             linha.match(/^####+?\s*\?\?\s*\*\*\s*Nome da Peça:\s*\*\*\s*(.+)/i);
      
      if (secaoPecaMatch) {
        // Salvar cotação anterior se existir
        if (cotacaoAtual.nomePeca && cotacaoAtual.tipoCotacao) {
          console.log(`   📦 Salvando cotação: ${cotacaoAtual.nomePeca} (${cotacaoAtual.tipoCotacao})`);
          await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
          totalSalvas++;
        }
        
        nomePecaAtual = secaoPecaMatch[1].replace(/\*/g, '').trim();
        dentroDeSecaoPeca = true;
        cotacaoAtual = { nomePeca: nomePecaAtual };
        cotacoesEncontradas++;
        console.log(`   🔧 Nova peça detectada na resposta: "${nomePecaAtual}"`);
        
        // Tentar fazer matching com peças do banco
        const pecaEncontrada = pecas.find(p => {
          const nomeBanco = p.NomePeca.toLowerCase();
          const nomeResposta = nomePecaAtual.toLowerCase();
          return nomeBanco.includes(nomeResposta) || 
                 nomeResposta.includes(nomeBanco) ||
                 nomeBanco.split(' ').some((palavra) => 
                   palavra.length > 3 && nomeResposta.includes(palavra)
                 );
        });
        
        if (pecaEncontrada) {
          console.log(`   ✓ Match encontrado com: "${pecaEncontrada.NomePeca}" (ID: ${pecaEncontrada.Id})`);
        } else {
          console.warn(`   ⚠️  Nenhum match direto encontrado para: "${nomePecaAtual}"`);
        }
        
        continue;
      }

      if (!dentroDeSecaoPeca) continue;

      // Detectar tipo de cotação
      const isEcommerce = 
        linha.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*e-Commerce/i) ||
        linha.match(/^\*\*\s*Tipo:\s*\*\*\s*e-Commerce/i) ||
        linha.match(/^\s*\*\s*\*\*E-commerce\s*-\s*Opção/i) ||
        linha.match(/^\s*\*\s*\*\*e-Commerce\s*-\s*Opção/i) ||
        linha.match(/🛒.*e-Commerce/i) ||
        linha.match(/Opções\s+e-Commerce/i);
      
      const isLojaFisica = 
        linha.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*Loja\s+F[ií]sica/i) ||
        linha.match(/^\*\*\s*Tipo:\s*\*\*\s*Loja\s+F[ií]sica/i) ||
        linha.match(/^\s*\*\s*\*\*Loja\s+F[ií]sica\s*-\s*Opção/i) ||
        linha.match(/📍.*Loja\s+F[ií]sica/i) ||
        linha.match(/Opções\s+Loja\s+F[ií]sica/i);

      if (isEcommerce) {
        console.log(`   ✓ DETECTADO: E-Commerce na linha ${i}`);
        if (cotacaoAtual.tipoCotacao) {
          console.log(`   💾 Salvando cotação anterior antes de nova: ${cotacaoAtual.nomePeca} (${cotacaoAtual.tipoCotacao})`);
          await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
          totalSalvas++;
        }
        cotacaoAtual = { nomePeca: nomePecaAtual, tipoCotacao: 'E-Commerce' };
        console.log(`   🛒 Tipo detectado: E-Commerce para ${nomePecaAtual}`);
      } else if (isLojaFisica) {
        console.log(`   ✓ DETECTADO: Loja Física na linha ${i}`);
        if (cotacaoAtual.tipoCotacao) {
          console.log(`   💾 Salvando cotação anterior antes de nova: ${cotacaoAtual.nomePeca} (${cotacaoAtual.tipoCotacao})`);
          await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
          totalSalvas++;
        }
        cotacaoAtual = { nomePeca: nomePecaAtual, tipoCotacao: 'Loja Física' };
        console.log(`   🏪 Tipo detectado: Loja Física para ${nomePecaAtual}`);
      }

      // Extrair link
      if (linha.match(/\?\?\s*\*\*\s*Link\/Endereço:\s*\*\*/i) || 
          linha.match(/\*\s*\*\*Link\/Endereço:\s*\*\*/i) ||
          linha.match(/Link\/Endereço:/i)) {
        const linkMatch = linha.match(/(https?:\/\/[^\s\)\]]+)/);
        if (linkMatch && !cotacaoAtual.link) {
          cotacaoAtual.link = linkMatch[1];
          console.log(`   🔗 Link extraído: ${linkMatch[1].substring(0, 50)}...`);
        }
      } else if (linha.includes('http://') || linha.includes('https://')) {
        const linkMatch = linha.match(/(https?:\/\/[^\s\)\]]+)/);
        if (linkMatch && !cotacaoAtual.link) {
          cotacaoAtual.link = linkMatch[1];
        }
      }

      // Extrair preço
      if (linha.match(/\?\?\s*\*\*\s*Preço:/i) || 
          linha.match(/\*\s*\*\*Preço:/i) || 
          linha.includes('R$') || 
          linha.includes('Preço:') || 
          linha.match(/💰|💵/)) {
        
        const precoRangeMatch = linha.match(/R\$\s*([\d.,]+)\s*[-–]\s*R\$\s*([\d.,]+)/);
        if (precoRangeMatch) {
          cotacaoAtual.precoMinimo = parseFloat(precoRangeMatch[1].replace(/\./g, '').replace(',', '.'));
          cotacaoAtual.precoMaximo = parseFloat(precoRangeMatch[2].replace(/\./g, '').replace(',', '.'));
          console.log(`   💰 Preço extraído: R$ ${cotacaoAtual.precoMinimo} - R$ ${cotacaoAtual.precoMaximo}`);
        } else {
          const precoMatch = linha.match(/R\$\s*([\d.,]+)/);
          if (precoMatch && !cotacaoAtual.preco) {
            cotacaoAtual.preco = parseFloat(precoMatch[1].replace(/\./g, '').replace(',', '.'));
            console.log(`   💰 Preço extraído: R$ ${cotacaoAtual.preco}`);
          }
        }
      }
    }

    // Salvar última cotação
    if (cotacaoAtual.nomePeca && cotacaoAtual.tipoCotacao) {
      console.log(`   📦 Salvando última cotação: ${cotacaoAtual.nomePeca} (${cotacaoAtual.tipoCotacao})`);
      await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
      totalSalvas++;
    }

    console.log(`\n📊 Resumo do Parser:`);
    console.log(`   Peças detectadas na resposta: ${cotacoesEncontradas}`);
    console.log(`   Cotações salvas no banco: ${totalSalvas}`);

    return totalSalvas;
  } catch (error) {
    console.error('❌ Erro no parser:', error);
    throw error;
  }
}

/**
 * Salva uma cotação individual no banco de dados
 */
async function salvarCotacao(cotacao, pecas, conversaId, pool) {
  try {
    console.log(`\n  🔍 Tentando salvar cotação: ${cotacao.nomePeca} (${cotacao.tipoCotacao})`);
    
    // Encontrar peça correspondente
    const peca = pecas.find(p => 
      p.NomePeca.toLowerCase().includes(cotacao.nomePeca.toLowerCase()) ||
      cotacao.nomePeca.toLowerCase().includes(p.NomePeca.toLowerCase())
    );

    if (!peca) {
      console.warn(`  ⚠️  Peça não encontrada para cotação: ${cotacao.nomePeca}`);
      console.warn(`  📋 Peças disponíveis: ${pecas.map(p => p.NomePeca).join(', ')}`);
      return;
    }

    console.log(`  ✓ Peça encontrada: ${peca.NomePeca} (ID: ${peca.Id})`);

    // Validar tipo de cotação
    if (!cotacao.tipoCotacao || !['E-Commerce', 'Loja Física'].includes(cotacao.tipoCotacao)) {
      console.warn(`  ⚠️  Tipo de cotação inválido: ${cotacao.tipoCotacao}`);
      return;
    }

    console.log(`  📝 Dados da cotação:`);
    console.log(`     - ConversaId: ${conversaId}`);
    console.log(`     - PecaId: ${peca.Id}`);
    console.log(`     - Tipo: ${cotacao.tipoCotacao}`);
    console.log(`     - Preço: ${cotacao.preco || `${cotacao.precoMinimo} - ${cotacao.precoMaximo}`}`);
    console.log(`     - Link: ${cotacao.link ? 'Sim' : 'Não'}`);

    // Registrar cotação
    const result = await pool
      .request()
      .input('ConversaId', conversaId)
      .input('ProblemaId', peca.ProblemaId || null)
      .input('PecaIdentificadaId', peca.Id)
      .input('NomePeca', cotacao.nomePeca)
      .input('TipoCotacao', cotacao.tipoCotacao)
      .input('Link', cotacao.link || null)
      .input('Endereco', cotacao.endereco || null)
      .input('NomeLoja', cotacao.nomeLoja || null)
      .input('Telefone', cotacao.telefone || null)
      .input('Preco', cotacao.preco || null)
      .input('PrecoMinimo', cotacao.precoMinimo || null)
      .input('PrecoMaximo', cotacao.precoMaximo || null)
      .input('CondicoesPagamento', cotacao.condicoesPagamento || null)
      .input('Observacoes', cotacao.observacoes || null)
      .input('Disponibilidade', cotacao.disponibilidade || null)
      .input('PrazoEntrega', cotacao.prazoEntrega || null)
      .input('EstadoPeca', cotacao.estadoPeca || null)
      .execute('AIHT_sp_RegistrarCotacao');

    console.log(`  🔄 Stored procedure executada, verificando resultado...`);
    console.log(`     - Recordsets: ${result.recordsets?.length || 0}`);
    console.log(`     - Recordset: ${result.recordset?.length || 0} registros`);
    console.log(`     - RowsAffected: ${result.rowsAffected}`);
    
    if (result.recordset && result.recordset.length > 0) {
      const cotacaoSalva = result.recordset[0];
      console.log(`  ✅ Cotação salva com sucesso! ID: ${cotacaoSalva.Id}`);
      console.log(`     DataCotacao: ${cotacaoSalva.DataCotacao}`);
    } else {
      console.warn(`  ⚠️  Stored procedure executada mas sem retorno`);
    }
  } catch (error) {
    console.error(`  ❌ Erro ao salvar cotação ${cotacao.nomePeca}:`);
    console.error(`     Mensagem: ${error.message}`);
    console.error(`     Código: ${error.code}`);
    console.error(`     Número: ${error.number}`);
    if (error.originalError) {
      console.error(`     Erro SQL Original: ${error.originalError.message}`);
    }
    throw error;
  }
}

/**
 * Processar cotações históricas
 */
async function processarCotacoesHistoricas() {
  try {
    console.log('🔌 Conectando ao banco de dados...');
    const pool = await sql.connect(config);
    
    // Buscar respostas da IA
    console.log('📊 Buscando respostas da IA...\n');
    const result = await pool.request()
      .query(`SELECT Id, ConversaId, RespostaRecebida 
              FROM [AIHT_LogChamadasIA] 
              WHERE Id IN (61,59,57,55,53,51)
              ORDER BY Id DESC`);
    
    console.log(`✓ ${result.recordset.length} respostas encontradas\n`);
    
    let totalGeralCotacoes = 0;
    
    // Processar cada resposta
    for (const log of result.recordset) {
      console.log('\n' + '='.repeat(80));
      console.log(`📝 Processando Log ID: ${log.Id} | ConversaId: ${log.ConversaId}`);
      console.log('='.repeat(80) + '\n');
      
      const resposta = log.RespostaRecebida;
      if (!resposta) {
        console.log('⚠️  Resposta vazia\n');
        continue;
      }
      
      // Buscar peças identificadas para esta conversa
      const pecasResult = await pool.request()
        .input('conversaId', sql.Int, log.ConversaId)
        .query(`SELECT Id, NomePeca, ProblemaId 
                FROM [AIHT_PecasIdentificadas] 
                WHERE ConversaId = @conversaId`);
      
      const pecas = pecasResult.recordset;
      
      if (pecas.length === 0) {
        console.log('⚠️  Nenhuma peça identificada para esta conversa\n');
        continue;
      }
      
      // Processar cotações
      try {
        const totalCotacoes = await parsearESalvarCotacoes(
          resposta,
          pecas,
          log.ConversaId,
          pool
        );
        
        totalGeralCotacoes += totalCotacoes;
        console.log(`\n✅ Log ${log.Id} processado: ${totalCotacoes} cotações salvas`);
      } catch (error) {
        console.error(`\n❌ Erro ao processar log ${log.Id}:`, error.message);
      }
    }
    
    console.log('\n' + '='.repeat(80));
    console.log(`🎉 PROCESSAMENTO CONCLUÍDO!`);
    console.log(`   Total de cotações salvas: ${totalGeralCotacoes}`);
    console.log('='.repeat(80));
    
    // Verificar total no banco
    const verificacao = await pool.request()
      .query(`SELECT COUNT(*) AS Total FROM AIHT_CotacoesPecas`);
    
    console.log(`\n📊 Verificação final:`);
    console.log(`   Total de cotações na tabela: ${verificacao.recordset[0].Total}`);
    
    await pool.close();
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
    console.error(error.stack);
  }
}

// Executar processamento
processarCotacoesHistoricas();
