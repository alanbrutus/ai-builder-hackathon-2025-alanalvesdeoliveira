import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';

export async function GET(
  request: Request,
  { params }: { params: { pecaId: string } }
) {
  try {
    const pecaId = parseInt(params.pecaId);

    if (isNaN(pecaId)) {
      return NextResponse.json({
        success: false,
        error: 'ID da peça inválido'
      }, { status: 400 });
    }

    const pool = await getConnection();

    // Buscar cotações da peça
    const result = await pool
      .request()
      .input('PecaIdentificadaId', pecaId)
      .execute('AIHT_sp_ListarCotacoesPeca');

    const cotacoes = result.recordset;

    console.log(`📋 ${cotacoes.length} cotações encontradas para peça ${pecaId}`);

    return NextResponse.json({
      success: true,
      pecaId,
      total: cotacoes.length,
      cotacoes
    });

  } catch (error: any) {
    console.error('❌ Erro ao listar cotações da peça:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
