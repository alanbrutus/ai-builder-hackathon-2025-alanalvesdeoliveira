import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';

export async function GET() {
  try {
    const pool = await getConnection();
    const result = await pool.request().query('SELECT 1 AS test');
    
    return NextResponse.json({
      success: true,
      message: 'Conexão com SQL Server OK!',
      data: result.recordset
    });
  } catch (error: any) {
    console.error('Erro de conexão:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      code: error.code,
      details: error.toString()
    }, { status: 500 });
  }
}
