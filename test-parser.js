/**
 * Script de teste do parser de cotações
 * Busca respostas reais do banco e testa o parser
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

async function testarParser() {
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
    
    // Testar cada resposta
    for (const log of result.recordset) {
      console.log('='.repeat(80));
      console.log(`📝 Testando Log ID: ${log.Id} | ConversaId: ${log.ConversaId}`);
      console.log('='.repeat(80));
      
      const resposta = log.RespostaRecebida;
      if (!resposta) {
        console.log('⚠️  Resposta vazia\n');
        continue;
      }
      
      // Buscar peças identificadas para esta conversa
      const pecasResult = await pool.request()
        .input('conversaId', sql.Int, log.ConversaId)
        .query(`SELECT Id, NomePeca 
                FROM [AIHT_PecasIdentificadas] 
                WHERE ConversaId = @conversaId`);
      
      const pecas = pecasResult.recordset;
      console.log(`\n📋 Peças identificadas no banco (${pecas.length}):`);
      pecas.forEach(p => console.log(`   - ${p.NomePeca} (ID: ${p.Id})`));
      
      // Analisar resposta
      console.log(`\n🔍 Analisando resposta (${resposta.length} caracteres)...\n`);
      
      const linhas = resposta.split('\n');
      console.log(`   Total de linhas: ${linhas.length}`);
      
      // Procurar padrões importantes
      let secoesPeca = 0;
      let tiposEcommerce = 0;
      let tiposLojaFisica = 0;
      let linhasComHashtag = 0;
      let linhasComInterrogacao = 0;
      
      console.log('\n📌 Linhas importantes detectadas:\n');
      
      for (let i = 0; i < linhas.length; i++) {
        const linha = linhas[i].trim();
        
        // Detectar seções de peça
        if (linha.match(/^####+?\s*\*?\*?\s*\d+\.\s+(.+)/) || 
            linha.match(/^####+?\s*\?\?\s*\*\*\s*Nome da Peça:\s*\*\*\s*(.+)/i)) {
          secoesPeca++;
          console.log(`   Linha ${i}: [SEÇÃO PEÇA] ${linha.substring(0, 80)}`);
        }
        
        // Detectar tipos
        if (linha.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*e-Commerce/i) ||
            linha.match(/^\s*\*\s*\*\*E-commerce\s*-\s*Opção/i)) {
          tiposEcommerce++;
          console.log(`   Linha ${i}: [E-COMMERCE] ${linha.substring(0, 80)}`);
        }
        
        if (linha.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*Loja\s+F[ií]sica/i) ||
            linha.match(/^\s*\*\s*\*\*Loja\s+F[ií]sica\s*-\s*Opção/i)) {
          tiposLojaFisica++;
          console.log(`   Linha ${i}: [LOJA FÍSICA] ${linha.substring(0, 80)}`);
        }
        
        // Contar linhas com padrões
        if (linha.includes('###')) linhasComHashtag++;
        if (linha.includes('??')) linhasComInterrogacao++;
      }
      
      console.log(`\n📊 Resumo da análise:`);
      console.log(`   - Seções de peça detectadas: ${secoesPeca}`);
      console.log(`   - Tipos E-Commerce detectados: ${tiposEcommerce}`);
      console.log(`   - Tipos Loja Física detectados: ${tiposLojaFisica}`);
      console.log(`   - Linhas com ###: ${linhasComHashtag}`);
      console.log(`   - Linhas com ??: ${linhasComInterrogacao}`);
      
      // Mostrar primeiras linhas com ### ou ??
      console.log(`\n🔎 Primeiras 5 linhas com ### ou ??:\n`);
      let count = 0;
      for (let i = 0; i < linhas.length && count < 5; i++) {
        const linha = linhas[i].trim();
        if (linha.includes('###') || linha.includes('??')) {
          console.log(`   Linha ${i}: "${linha}"`);
          count++;
        }
      }
      
      console.log('\n');
    }
    
    await pool.close();
    console.log('✅ Teste concluído!');
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
    console.error(error.stack);
  }
}

// Executar teste
testarParser();
