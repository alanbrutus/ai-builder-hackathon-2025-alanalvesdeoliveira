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

    // Buscar cotações da conversa
    const result = await pool
      .request()
      .input('ConversaId', conversaId)
      .execute('AIHT_sp_ListarCotacoesConversa');

    const cotacoes = result.recordset;

    console.log(`📋 ${cotacoes.length} cotações encontradas para conversa ${conversaId}`);

    return NextResponse.json({
      success: true,
      conversaId,
      total: cotacoes.length,
      cotacoes
    });

  } catch (error: any) {
    console.error('❌ Erro ao listar cotações:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
