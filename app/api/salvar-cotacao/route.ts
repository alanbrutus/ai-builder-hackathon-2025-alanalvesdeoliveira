import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';
import sql from 'mssql';

export interface CotacaoInput {
  conversaId: number;
  problemaId?: number;
  pecaIdentificadaId: number;
  nomePeca: string;
  tipoCotacao: 'E-Commerce' | 'Loja Física';
  link?: string;
  endereco?: string;
  nomeLoja?: string;
  telefone?: string;
  preco?: number;
  precoMinimo?: number;
  precoMaximo?: number;
  condicoesPagamento?: string;
  observacoes?: string;
  disponibilidade?: string;
  prazoEntrega?: string;
  estadoPeca?: 'Nova' | 'Usada' | 'Recondicionada';
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { cotacoes } = body as { cotacoes: CotacaoInput[] };

    if (!cotacoes || !Array.isArray(cotacoes) || cotacoes.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'Lista de cotações é obrigatória'
      }, { status: 400 });
    }

    const pool = await getConnection();
    const cotacoesSalvas = [];

    // Salvar cada cotação
    for (const cotacao of cotacoes) {
      try {
        const result = await pool
          .request()
          .input('ConversaId', sql.Int, cotacao.conversaId)
          .input('ProblemaId', sql.Int, cotacao.problemaId || null)
          .input('PecaIdentificadaId', sql.Int, cotacao.pecaIdentificadaId)
          .input('NomePeca', sql.NVarChar(200), cotacao.nomePeca)
          .input('TipoCotacao', sql.NVarChar(50), cotacao.tipoCotacao)
          .input('Link', sql.NVarChar(500), cotacao.link || null)
          .input('Endereco', sql.NVarChar(500), cotacao.endereco || null)
          .input('NomeLoja', sql.NVarChar(200), cotacao.nomeLoja || null)
          .input('Telefone', sql.NVarChar(50), cotacao.telefone || null)
          .input('Preco', sql.Decimal(10, 2), cotacao.preco || null)
          .input('PrecoMinimo', sql.Decimal(10, 2), cotacao.precoMinimo || null)
          .input('PrecoMaximo', sql.Decimal(10, 2), cotacao.precoMaximo || null)
          .input('CondicoesPagamento', sql.NVarChar(500), cotacao.condicoesPagamento || null)
          .input('Observacoes', sql.NVarChar(sql.MAX), cotacao.observacoes || null)
          .input('Disponibilidade', sql.NVarChar(100), cotacao.disponibilidade || null)
          .input('PrazoEntrega', sql.NVarChar(100), cotacao.prazoEntrega || null)
          .input('EstadoPeca', sql.NVarChar(50), cotacao.estadoPeca || null)
          .execute('AIHT_sp_RegistrarCotacao');

        if (result.recordset && result.recordset.length > 0) {
          cotacoesSalvas.push(result.recordset[0]);
        }
      } catch (error: any) {
        console.error(`❌ Erro ao salvar cotação para ${cotacao.nomePeca}:`, error.message);
        // Continua salvando as outras cotações mesmo se uma falhar
      }
    }

    console.log(`✅ ${cotacoesSalvas.length} de ${cotacoes.length} cotações salvas com sucesso`);

    return NextResponse.json({
      success: true,
      totalSolicitadas: cotacoes.length,
      totalSalvas: cotacoesSalvas.length,
      cotacoes: cotacoesSalvas
    });

  } catch (error: any) {
    console.error('❌ Erro ao salvar cotações:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
