import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';

// POST - Criar nova conversa
export async function POST(request: Request) {
  try {
    const { nomeCliente, grupoEmpresarialId, fabricanteId, modeloId } = await request.json();

    if (!nomeCliente || !grupoEmpresarialId || !fabricanteId || !modeloId) {
      return NextResponse.json({
        success: false,
        error: 'Dados incompletos'
      }, { status: 400 });
    }

    const pool = await getConnection();
    const result = await pool
      .request()
      .input('NomeCliente', nomeCliente)
      .input('GrupoEmpresarialId', grupoEmpresarialId)
      .input('FabricanteId', fabricanteId)
      .input('ModeloId', modeloId)
      .execute('AIHT_sp_CriarConversa');

    return NextResponse.json({
      success: true,
      data: result.recordset[0]
    });
  } catch (error: any) {
    console.error('Erro ao criar conversa:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
