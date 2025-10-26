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
    // Parsear resposta da IA para extrair cotações
    const linhas = respostaIA.split('\n');
    let cotacaoAtual: any = {};
    let dentroDeSecaoPeca = false;
    let nomePecaAtual = '';

    for (let i = 0; i < linhas.length; i++) {
      const linha = linhas[i].trim();

      // Detectar início de seção de peça (ex: "### 1. Bieleta da Barra Estabilizadora")
      if (linha.match(/^###\s+\d+\.\s+(.+)/)) {
        // Salvar cotação anterior se existir
        if (cotacaoAtual.nomePeca) {
          await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
          totalSalvas++;
        }
        
        const match = linha.match(/^###\s+\d+\.\s+(.+)/);
        nomePecaAtual = match ? match[1].trim() : '';
        dentroDeSecaoPeca = true;
        cotacaoAtual = { nomePeca: nomePecaAtual };
        continue;
      }

      if (!dentroDeSecaoPeca) continue;

      // Detectar tipo de cotação (suporta múltiplos formatos)
      const isEcommerce = linha.includes('e-Commerce') || 
                          linha.includes('e-commerce') ||
                          linha.includes('E-Commerce') ||
                          linha.match(/\*\*\s*Tipo:\s*\*\*\s*e-Commerce/i);
      
      const isLojaFisica = linha.includes('Loja Física') || 
                           linha.includes('loja física') ||
                           linha.includes('Loja Fisica') ||
                           linha.match(/\*\*\s*Tipo:\s*\*\*\s*Loja\s+F[ií]sica/i);

      if (isEcommerce) {
        if (cotacaoAtual.tipoCotacao) {
          await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
          totalSalvas++;
        }
        cotacaoAtual = { nomePeca: nomePecaAtual, tipoCotacao: 'E-Commerce' };
      } else if (isLojaFisica) {
        if (cotacaoAtual.tipoCotacao) {
          await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
          totalSalvas++;
        }
        cotacaoAtual = { nomePeca: nomePecaAtual, tipoCotacao: 'Loja Física' };
      }

      // Extrair link (e-commerce)
      if (linha.includes('http://') || linha.includes('https://')) {
        const linkMatch = linha.match(/(https?:\/\/[^\s\)]+)/);
        if (linkMatch && !cotacaoAtual.link) {
          cotacaoAtual.link = linkMatch[1];
        }
      }

      // Extrair endereço (loja física)
      if (linha.includes('Endereço:') || linha.match(/[A-Z][a-z]+\s+[A-Z][a-z]+.*\d+.*-.*,/)) {
        const enderecoMatch = linha.match(/:\s*(.+)/);
        if (enderecoMatch) {
          cotacaoAtual.endereco = enderecoMatch[1].trim();
        } else if (!cotacaoAtual.endereco && linha.match(/[A-Z][a-z]+.*\d+/)) {
          cotacaoAtual.endereco = linha.replace(/^\*\*/, '').replace(/\*\*$/, '').trim();
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
      if (linha.includes('R$') || linha.includes('Preço:') || linha.match(/💰|💵/)) {
        // Faixa de preço: R$ 150,00 - R$ 200,00 ou R$ 150 - R$ 200
        const faixaMatch = linha.match(/R\$\s*([\d.,]+)\s*-\s*R\$\s*([\d.,]+)/);
        if (faixaMatch && !cotacaoAtual.precoMinimo) {
          const min = faixaMatch[1].replace(/\./g, '').replace(',', '.');
          const max = faixaMatch[2].replace(/\./g, '').replace(',', '.');
          cotacaoAtual.precoMinimo = parseFloat(min);
          cotacaoAtual.precoMaximo = parseFloat(max);
        } else {
          // Preço único: R$ 189,90
          const unicoMatch = linha.match(/R\$\s*([\d.,]+)(?!\s*-)/);
          if (unicoMatch && !cotacaoAtual.preco && !cotacaoAtual.precoMinimo) {
            const preco = unicoMatch[1].replace(/\./g, '').replace(',', '.');
            cotacaoAtual.preco = parseFloat(preco);
          }
        }
      }

      // Extrair condições de pagamento (múltiplos formatos)
      if (linha.match(/Condições de Pagamento:|Pagamento:|💳/i)) {
        const pagamentoMatch = linha.match(/(?:Condições de )?Pagamento:\s*\*?\*?\s*(.+)/i);
        if (pagamentoMatch && !cotacaoAtual.condicoesPagamento) {
          cotacaoAtual.condicoesPagamento = pagamentoMatch[1].replace(/\*\*/g, '').replace(/\*/g, '').trim();
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
      
      // Extrair observações gerais (seção de observações)
      if (linha.match(/^\s*\*\s+\*\*Observações/i) || linha.match(/^📝\s*\*\*Observações/i)) {
        // Marcar que entramos na seção de observações
        cotacaoAtual.dentroObservacoes = true;
      } else if (cotacaoAtual.dentroObservacoes && linha.match(/^\s*\*/)) {
        // Capturar linhas de observação
        const obsTexto = linha.replace(/^\s*\*\s*\*?\*?/, '').replace(/\*\*/g, '').trim();
        if (obsTexto && obsTexto.length > 5) {
          if (!cotacaoAtual.observacoes) {
            cotacaoAtual.observacoes = obsTexto;
          } else {
            cotacaoAtual.observacoes += '; ' + obsTexto;
          }
        }
      }
    }

    // Salvar última cotação
    if (cotacaoAtual.nomePeca && cotacaoAtual.tipoCotacao) {
      await salvarCotacao(cotacaoAtual, pecas, conversaId, pool);
      totalSalvas++;
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
    // Encontrar peça correspondente
    const peca = pecas.find(p => 
      p.NomePeca.toLowerCase().includes(cotacao.nomePeca.toLowerCase()) ||
      cotacao.nomePeca.toLowerCase().includes(p.NomePeca.toLowerCase())
    );

    if (!peca) {
      console.warn(`⚠️  Peça não encontrada para cotação: ${cotacao.nomePeca}`);
      return;
    }

    // Validar tipo de cotação
    if (!cotacao.tipoCotacao || !['E-Commerce', 'Loja Física'].includes(cotacao.tipoCotacao)) {
      console.warn(`⚠️  Tipo de cotação inválido: ${cotacao.tipoCotacao}`);
      return;
    }

    // Registrar cotação
    await pool
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

    console.log(`  ✅ Cotação salva: ${cotacao.nomePeca} (${cotacao.tipoCotacao})`);
  } catch (error) {
    console.error(`  ❌ Erro ao salvar cotação ${cotacao.nomePeca}:`, error);
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

    // 4. Substituir variáveis no prompt
    const fabricanteVeiculo = pecas[0]?.MarcaVeiculo || 'Veículo';
    const modeloVeiculo = pecas[0]?.ModeloVeiculo || '';
    
    // Formatar lista de peças
    const listaPecas = pecas.map((p, i) => 
      `${i + 1}. ${p.NomePeca} - ${p.CodigoPeca || 'Sem código'}`
    ).join('\n');

    // Substituir variáveis
    const promptCotacao = promptTemplate
      .replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo)
      .replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo)
      .replace(/\{\{lista_pecas\}\}/g, listaPecas);

    console.log('📝 Prompt montado com variáveis substituídas');

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
      .input('TipoChamada', 'cotacao')
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
