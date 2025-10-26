import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';

export async function GET(
  request: Request,
  { params }: { params: { conversaId: string } }
) {
  try {
    const conversaId = parseInt(params.conversaId);

    if (isNaN(conversaId)) {
      return NextResponse.json({
        success: false,
        error: 'ID da conversa inválido'
      }, { status: 400 });
    }

    const pool = await getConnection();

    // Buscar resumo das cotações
    const result = await pool
      .request()
      .input('ConversaId', conversaId)
      .execute('AIHT_sp_ResumoCotacoes');

    // O resultado vem em dois recordsets
    const recordsets = result.recordsets as any[];
    const resumoGeral = recordsets[0]?.[0] || {};
    const resumoPorPeca = recordsets[1] || [];

    console.log(`📊 Resumo de cotações para conversa ${conversaId}`);
    console.log(`   Total de cotações: ${resumoGeral.TotalCotacoes || 0}`);
    console.log(`   Total de peças: ${resumoGeral.TotalPecas || 0}`);

    return NextResponse.json({
      success: true,
      conversaId,
      resumoGeral,
      resumoPorPeca
    });

  } catch (error: any) {
    console.error('❌ Erro ao buscar resumo de cotações:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
