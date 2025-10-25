import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';

export async function GET() {
  try {
    const pool = await getConnection();
    
    // Testar criação de conversa
    const result = await pool
      .request()
      .input('NomeCliente', 'Teste')
      .input('GrupoEmpresarialId', 1)
      .input('FabricanteId', 1)
      .input('ModeloId', 1)
      .execute('AIHT_sp_CriarConversa');

    return NextResponse.json({
      success: true,
      message: 'Stored procedure existe e funciona!',
      data: result.recordset[0]
    });
  } catch (error: any) {
    console.error('ERRO DETALHADO:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      code: error.code,
      number: error.number,
      details: error.toString(),
      stack: error.stack
    }, { status: 500 });
  }
}
