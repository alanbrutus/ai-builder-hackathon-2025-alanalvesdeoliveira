import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';
import { sendToGemini } from '@/lib/gemini';
import sql from 'mssql';

/**
 * Parseia a resposta da IA e salva as cotações no banco de dados
 */
async function parsearESalvarCotacoes(
  respostaIA: string,
  pecas: any[],
  conversaId: number,
  pool: sql.ConnectionPool
): Promise<number> {
  let totalSalvas = 0;

  try {
    console.log('🔍 Iniciando parser de cotações...');
    console.log(`   Total de peças identificadas: ${pecas.length}`);
    console.log(`   📋 Peças identificadas no banco:`);
    pecas.forEach(p => console.log(`      - ${p.NomePeca} (ID: ${p.Id})`));
    
    // Parsear resposta da IA para extrair cotações
    const linhas = respostaIA.split('\n');
    let cotacaoAtual: any = {};
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
      // Formato 1: "### 1. Bieleta da Barra Estabilizadora"
      // Formato 2: "#### **1. Sensor de temperatura do motor (ECT)**"
      // Formato 3: "#### ?? **Nome da Peça:** Coxins do Motor"
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
                 // Matching por palavras-chave principais
                 nomeBanco.split(' ').some((palavra: string) => 
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

      // Detectar tipo de cotação (suporta múltiplos formatos)
      // FORMATO SOLICITADO NO PROMPT:
      // "?? **Tipo:** e-Commerce" ou "?? **Tipo:** Loja Física"
      // 
      // FORMATO QUE A IA RETORNA:
      // "* **E-commerce - Opção 1 (Custo-Benefício)**"
      // "* **Loja Física - Opção (Consulta Local)**"
      //
      // OUTROS FORMATOS POSSÍVEIS:
      // "**🛒 Opções e-Commerce:**"
      // "**Tipo:** e-Commerce"
      
      const isEcommerce = 
        // Formato solicitado: ?? **Tipo:** e-Commerce
        linha.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*e-Commerce/i) ||
        linha.match(/^\*\*\s*Tipo:\s*\*\*\s*e-Commerce/i) ||
        // Formato que a IA retorna: * **E-commerce - Opção
        linha.match(/^\s*\*\s*\*\*E-commerce\s*-\s*Opção/i) ||
        linha.match(/^\s*\*\s*\*\*e-Commerce\s*-\s*Opção/i) ||
        // Outros formatos
        linha.match(/🛒.*e-Commerce/i) ||
        linha.match(/Opções\s+e-Commerce/i);
      
      const isLojaFisica = 
        // Formato solicitado: ?? **Tipo:** Loja Física
        linha.match(/^\?\?\s*\*\*\s*Tipo:\s*\*\*\s*Loja\s+F[ií]sica/i) ||
        linha.match(/^\*\*\s*Tipo:\s*\*\*\s*Loja\s+F[ií]sica/i) ||
        // Formato que a IA retorna: * **Loja Física - Opção
        linha.match(/^\s*\*\s*\*\*Loja\s+F[ií]sica\s*-\s*Opção/i) ||
        // Outros formatos
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

      // Extrair link (e-commerce) - múltiplos formatos
      // Formato 1: "?? **Link/Endereço:** [URL]"
      // Formato 2: "* **Link/Endereço:** [Exemplo: URL](URL)"
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

      // Extrair endereço (loja física) - múltiplos formatos
      // Formato 1: "?? **Link/Endereço:** [Endereço]"
      // Formato 2: "* **Link/Endereço:** **Nome Loja** - Endereço completo"
      if ((linha.match(/\?\?\s*\*\*\s*Link\/Endereço:\s*\*\*/i) || 
           linha.match(/\*\s*\*\*Link\/Endereço:\s*\*\*/i)) && 
          cotacaoAtual.tipoCotacao === 'Loja Física') {
        // Extrair nome da loja e endereço
        const lojaEnderecoMatch = linha.match(/Link\/Endereço:\s*\*\*\s*([^*]+)\*\*\s*-\s*(.+)/i);
        if (lojaEnderecoMatch) {
          cotacaoAtual.nomeLoja = lojaEnderecoMatch[1].trim();
          cotacaoAtual.endereco = lojaEnderecoMatch[2].replace(/\*/g, '').trim();
          console.log(`   🏪 Loja: ${cotacaoAtual.nomeLoja}`);
          console.log(`   📍 Endereço: ${cotacaoAtual.endereco.substring(0, 50)}...`);
        } else {
          const enderecoMatch = linha.match(/Link\/Endereço:\s*\*?\*?\s*(.+)/i);
          if (enderecoMatch && !cotacaoAtual.endereco) {
            cotacaoAtual.endereco = enderecoMatch[1].replace(/\*/g, '').trim();
            console.log(`   📍 Endereço extraído: ${cotacaoAtual.endereco.substring(0, 50)}...`);
          }
        }
      } else if (linha.includes('Endereço:') || linha.match(/[A-Z][a-z]+\s+[A-Z][a-z]+.*\d+.*-.*,/)) {
        const enderecoMatch = linha.match(/:\s*(.+)/);
        if (enderecoMatch) {
          cotacaoAtual.endereco = enderecoMatch[1].trim();
        } else if (!cotacaoAtual.endereco && linha.match(/[A-Z][a-z]+.*\d+/)) {
          cotacaoAtual.endereco = linha.replace(/^\*\*/, '').replace(/\*\*$/, '').trim();
        }
      }

      // Extrair código - múltiplos formatos
      // Formato 1: "?? **Código:** [Código]"
      // Formato 2: "* **Código:** [Código]"
      if (linha.match(/\?\?\s*\*\*\s*Código:\s*\*\*/i) || 
          linha.match(/\*\s*\*\*Código:\s*\*\*/i)) {
        const codigoMatch = linha.match(/Código:\s*\*?\*?\s*(.+)/i);
        if (codigoMatch && !cotacaoAtual.codigo) {
          cotacaoAtual.codigo = codigoMatch[1].replace(/\*/g, '').trim();
        }
      }

      // Extrair nome da loja
      if (linha.includes('**') && linha.includes(':') && cotacaoAtual.tipoCotacao === 'Loja Física') {
        const lojaMatch = linha.match(/\*\*([^*:]+)\*\*:/);
        if (lojaMatch && !cotacaoAtual.nomeLoja) {
          cotacaoAtual.nomeLoja = lojaMatch[1].trim();
        }
      }

      // Extrair preço (suporta múltiplos formatos)
      // Formato 1: "?? **Preço:** R$ 150,00 - R$ 200,00"
      // Formato 2: "* **Preço:** R$ 150,00 - R$ 200,00"
      if (linha.match(/\?\?\s*\*\*\s*Preço:/i) || 
          linha.match(/\*\s*\*\*Preço:/i) || 
          linha.includes('R$') || 
          linha.includes('Preço:') || 
          linha.match(/💰|💵/)) {
        // Faixa de preço: R$ 150,00 - R$ 200,00 ou R$ 150 - R$ 200
        const faixaMatch = linha.match(/R\$\s*([\d.,]+)\s*-\s*R\$\s*([\d.,]+)/);
        if (faixaMatch && !cotacaoAtual.precoMinimo) {
          const min = faixaMatch[1].replace(/\./g, '').replace(',', '.');
          const max = faixaMatch[2].replace(/\./g, '').replace(',', '.');
          cotacaoAtual.precoMinimo = parseFloat(min);
          cotacaoAtual.precoMaximo = parseFloat(max);
          console.log(`   💰 Preço extraído: R$ ${cotacaoAtual.precoMinimo} - R$ ${cotacaoAtual.precoMaximo}`);
        } else {
          // Preço único: R$ 189,90
          const unicoMatch = linha.match(/R\$\s*([\d.,]+)(?!\s*-)/);
          if (unicoMatch && !cotacaoAtual.preco && !cotacaoAtual.precoMinimo) {
            const preco = unicoMatch[1].replace(/\./g, '').replace(',', '.');
            cotacaoAtual.preco = parseFloat(preco);
            console.log(`   💰 Preço extraído: R$ ${cotacaoAtual.preco}`);
          }
        }
      }

      // Extrair condições de pagamento (múltiplos formatos)
      // Formato 1: "?? **Condições de Pagamento:** [texto]"
      // Formato 2: "* **Condições de Pagamento:** [texto]"
      if (linha.match(/\?\?\s*\*\*\s*Condições de Pagamento:/i) || 
          linha.match(/\*\s*\*\*Condições de Pagamento:/i) ||
          linha.match(/Condições de Pagamento:|Pagamento:|💳/i)) {
        const pagamentoMatch = linha.match(/(?:Condições de )?Pagamento:\s*\*?\*?\s*(.+)/i);
        if (pagamentoMatch && !cotacaoAtual.condicoesPagamento) {
          cotacaoAtual.condicoesPagamento = pagamentoMatch[1].replace(/\*\*/g, '').replace(/\*/g, '').trim();
        }
      }

      // Extrair observações (múltiplos formatos)
      // Formato 1: "? **Observações:** [texto]"
      // Formato 2: "* **Observações:** [texto]"
      if (linha.match(/\?\s*\*\*\s*Observações:/i) || 
          linha.match(/\*\s*\*\*Observações:/i) ||
          linha.match(/^\s*\*\s+\*\*Observações/i) || 
          linha.match(/^📝\s*\*\*Observações/i)) {
        const obsMatch = linha.match(/Observações:\s*\*?\*?\s*(.+)/i);
        if (obsMatch && !cotacaoAtual.observacoes) {
          cotacaoAtual.observacoes = obsMatch[1].replace(/\*\*/g, '').replace(/\*/g, '').trim();
        } else {
          // Marcar que entramos na seção de observações
          cotacaoAtual.dentroObservacoes = true;
        }
      } else if (cotacaoAtual.dentroObservacoes && linha.match(/^\s*\*/)) {
        // Capturar linhas de observação
        const obsTexto = linha.replace(/^\s*\*\s*\*?\*?/, '').replace(/\*\*/g, '').trim();
        if (obsTexto && obsTexto.length > 5 && !obsTexto.match(/^\*\*[A-Z]/)) {
          if (!cotacaoAtual.observacoes) {
            cotacaoAtual.observacoes = obsTexto;
          } else {
            cotacaoAtual.observacoes += '; ' + obsTexto;
          }
        }
      }

      // Extrair disponibilidade (múltiplos formatos)
      if (linha.match(/Disponibilidade:|📦|✅/i)) {
        const dispMatch = linha.match(/Disponibilidade:\s*\*?\*?\s*(.+)/i);
        if (dispMatch && !cotacaoAtual.disponibilidade) {
          cotacaoAtual.disponibilidade = dispMatch[1].replace(/\*\*/g, '').replace(/\*/g, '').trim();
        }
      }

      // Extrair prazo de entrega (múltiplos formatos)
      if (linha.match(/Prazos? de Entrega:|🚚|📅/i)) {
        const prazoMatch = linha.match(/Prazos? de Entrega:\s*\*?\*?\s*(.+)/i);
        if (prazoMatch && !cotacaoAtual.prazoEntrega) {
          cotacaoAtual.prazoEntrega = prazoMatch[1].replace(/\*\*/g, '').replace(/\*/g, '').trim();
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
    
    if (totalSalvas === 0 && cotacoesEncontradas > 0) {
      console.warn(`⚠️  ATENÇÃO: Peças foram detectadas mas nenhuma cotação foi salva!`);
      console.warn(`   Possível causa: Tipo de cotação não foi detectado corretamente`);
      console.warn(`   Verifique o formato da resposta da IA`);
    }

  } catch (error) {
    console.error('❌ Erro ao parsear cotações:', error);
  }

  return totalSalvas;
}

/**
 * Salva uma cotação individual no banco de dados
 */
async function salvarCotacao(
  cotacao: any,
  pecas: any[],
  conversaId: number,
  pool: sql.ConnectionPool
): Promise<void> {
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
    console.log(`     - Endereço: ${cotacao.endereco ? 'Sim' : 'Não'}`);

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
      console.warn(`     Isso pode indicar que a SP não está retornando o SELECT final`);
    }
  } catch (error: any) {
    console.error(`  ❌ Erro ao salvar cotação ${cotacao.nomePeca}:`);
    console.error(`     Mensagem: ${error.message}`);
    console.error(`     Código: ${error.code}`);
    console.error(`     Número: ${error.number}`);
    if (error.originalError) {
      console.error(`     Erro SQL Original: ${error.originalError.message}`);
      console.error(`     SQL State: ${error.originalError.info?.sqlstate}`);
    }
    console.error(`     Stack completo: ${error.stack}`);
    throw error; // Re-lançar erro para ver no resumo
  }
}

export async function POST(request: Request) {
  try {
    const { conversaId, mensagemCliente } = await request.json();

    if (!conversaId) {
      return NextResponse.json({
        success: false,
        error: 'ID da conversa é obrigatório'
      }, { status: 400 });
    }

    const pool = await getConnection();

    // 1. Verificar se a mensagem tem intenção de cotação
    const intencaoResult = await pool
      .request()
      .input('Mensagem', mensagemCliente)
      .execute('AIHT_sp_VerificarIntencaoCotacao');

    const intencaoCotacao = intencaoResult.recordset[0]?.IntencaoCotacao;
    const palavrasEncontradas = intencaoResult.recordset[0]?.PalavrasEncontradas;

    console.log('🔍 Verificando intenção de cotação...');
    console.log('   Intenção detectada:', intencaoCotacao ? 'SIM' : 'NÃO');
    console.log('   Palavras encontradas:', palavrasEncontradas || 'nenhuma');

    if (!intencaoCotacao) {
      return NextResponse.json({
        success: true,
        intencaoCotacao: false,
        mensagem: 'Mensagem não indica intenção de cotação'
      });
    }

    // 2. Buscar peças identificadas na conversa
    const pecasResult = await pool
      .request()
      .input('ConversaId', conversaId)
      .execute('AIHT_sp_ListarPecasParaCotacao');

    const pecas = pecasResult.recordset;

    if (pecas.length === 0) {
      return NextResponse.json({
        success: true,
        intencaoCotacao: true,
        mensagem: 'Nenhuma peça foi identificada ainda nesta conversa.'
      });
    }

    console.log(`📦 ${pecas.length} peças encontradas para cotação`);

    // 3. Buscar prompt de cotação do banco de dados
    const promptResult = await pool
      .request()
      .input('Contexto', 'cotacao')
      .execute('AIHT_sp_ObterPromptPorContexto');

    let promptTemplate = promptResult.recordset[0]?.ConteudoPrompt;

    if (!promptTemplate) {
      console.warn('⚠️  Prompt de cotação não encontrado, usando padrão');
      promptTemplate = `Preciso que realize um processo de cotação para o {{fabricante_veiculo}} {{modelo_veiculo}} em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
{{lista_pecas}}
-- Fim Peças

Para cada peça, forneça: nome, tipo (e-Commerce/Loja Física), link/endereço, preço estimado e condições de pagamento.`;
    }

    // 4. Buscar informações do veículo da conversa
    const conversaResult = await pool
      .request()
      .input('ConversaId', conversaId)
      .query('SELECT VeiculoMarca, VeiculoModelo FROM AIHT_Conversas WHERE Id = @ConversaId');
    
    const conversa = conversaResult.recordset[0];
    const fabricanteVeiculo = conversa?.VeiculoMarca || 'Veículo';
    const modeloVeiculo = conversa?.VeiculoModelo || '';
    
    console.log(`🚗 Veículo: ${fabricanteVeiculo} ${modeloVeiculo}`);
    
    // Formatar lista de peças
    const listaPecas = pecas.map((p, i) => 
      `${i + 1}. ${p.NomePeca} - ${p.CodigoPeca || 'Sem código'}`
    ).join('\n');

    // Substituir variáveis
    const promptCotacao = promptTemplate
      .replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo)
      .replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo)
      .replace(/\{\{lista_pecas\}\}/g, listaPecas);

    console.log('📝 Prompt montado com variáveis substituídas:');
    console.log(`   Fabricante: ${fabricanteVeiculo}`);
    console.log(`   Modelo: ${modeloVeiculo}`);
    console.log(`   Peças: ${pecas.length}`);

    // 4. Enviar para Gemini
    console.log('🤖 Enviando para Gemini...');
    const inicioTempo = Date.now();
    const resultadoIA = await sendToGemini(promptCotacao, mensagemCliente);
    const tempoResposta = Date.now() - inicioTempo;

    if (!resultadoIA.success) {
      console.error('❌ Erro na resposta da IA:', resultadoIA.error);
      return NextResponse.json({
        success: false,
        error: resultadoIA.error
      }, { status: 500 });
    }

    console.log('✅ Cotação gerada com sucesso');

    // 5. Registrar log da chamada
    await pool
      .request()
      .input('ConversaId', conversaId)
      .input('TipoChamada', 'gerar-cotacao')
      .input('MensagemCliente', mensagemCliente || 'Mensagem não informada')
      .input('PromptEnviado', promptCotacao || 'Prompt não disponível')
      .input('RespostaRecebida', resultadoIA.response || '')
      .input('TempoResposta', tempoResposta)
      .input('Sucesso', resultadoIA.success ? 1 : 0)
      .input('MensagemErro', resultadoIA.error || null)
      .input('ModeloIA', 'gemini-pro')
      .execute('AIHT_sp_RegistrarChamadaIA');

    // 6. Parsear e salvar cotações no banco de dados
    console.log('💾 Parseando e salvando cotações no banco...');
    const cotacoesSalvas = await parsearESalvarCotacoes(
      resultadoIA.response || '',
      pecas,
      conversaId,
      pool
    );
    console.log(`✅ ${cotacoesSalvas} cotações salvas no banco de dados`);

    return NextResponse.json({
      success: true,
      intencaoCotacao: true,
      cotacao: resultadoIA.response,
      pecas: pecas,
      palavrasEncontradas: palavrasEncontradas,
      cotacoesSalvas: cotacoesSalvas
    });

  } catch (error: any) {
    console.error('❌ Erro ao gerar cotação:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
