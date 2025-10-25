import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';

export async function GET() {
  try {
    console.log('Tentando conectar ao SQL Server...');
    const pool = await getConnection();
    console.log('Conexão estabelecida!');
    
    const result = await pool.request().query('SELECT TOP 5 Id, Nome FROM AIHT_GruposEmpresariais');
    console.log('Query executada:', result.recordset);
    
    return NextResponse.json({
      success: true,
      message: 'Conexão com SQL Server OK!',
      grupos: result.recordset,
      totalGrupos: result.recordset.length
    });
  } catch (error: any) {
    console.error('ERRO DETALHADO:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      code: error.code,
      name: error.name,
      stack: error.stack,
      details: error.toString()
    }, { status: 500 });
  }
}
