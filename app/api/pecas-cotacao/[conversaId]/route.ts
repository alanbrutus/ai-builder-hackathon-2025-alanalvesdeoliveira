import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';

export async function GET(
  request: Request,
  { params }: { params: { conversaId: string } }
) {
  try {
    const conversaId = parseInt(params.conversaId);

    if (!conversaId || isNaN(conversaId)) {
      return NextResponse.json({
        success: false,
        error: 'ID da conversa inválido'
      }, { status: 400 });
    }

    const pool = await getConnection();
    
    // Buscar peças para cotação
    const result = await pool
      .request()
      .input('ConversaId', conversaId)
      .execute('AIHT_sp_ListarPecasParaCotacao');

    return NextResponse.json({
      success: true,
      pecas: result.recordset
    });

  } catch (error: any) {
    console.error('Erro ao buscar peças para cotação:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
