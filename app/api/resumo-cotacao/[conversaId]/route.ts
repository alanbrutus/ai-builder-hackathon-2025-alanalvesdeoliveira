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
    
    // Buscar resumo completo para cotação
    const result = await pool
      .request()
      .input('ConversaId', conversaId)
      .execute('AIHT_sp_ResumoCotacao');

    // A procedure retorna 3 recordsets:
    // 1. Informações da conversa
    // 2. Problemas identificados
    // 3. Peças identificadas
    
    const recordsets = result.recordsets as any[];
    
    return NextResponse.json({
      success: true,
      conversa: recordsets[0]?.[0] || null,
      problemas: recordsets[1] || [],
      pecas: recordsets[2] || []
    });

  } catch (error: any) {
    console.error('Erro ao buscar resumo de cotação:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
