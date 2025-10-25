import { NextResponse } from 'next/server';
import { executeStoredProcedure } from '@/lib/db';

export interface ModeloBusca {
  ModeloId: number;
  Modelo: string;
  Fabricante: string;
  GrupoEmpresarial: string;
  TipoVeiculo: string;
  Periodo: string;
  NomeCompleto: string;
  HierarquiaCompleta: string;
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const texto = searchParams.get('q');

    if (!texto || texto.trim().length < 2) {
      return NextResponse.json(
        {
          success: false,
          error: 'Texto de busca deve ter pelo menos 2 caracteres',
        },
        { status: 400 }
      );
    }

    const modelos = await executeStoredProcedure<ModeloBusca>(
      'AIHT_sp_BuscarModelosPorNome',
      { TextoBusca: texto }
    );

    return NextResponse.json({
      success: true,
      data: modelos,
    });
  } catch (error) {
    console.error('Erro ao buscar modelos:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro ao buscar modelos',
      },
      { status: 500 }
    );
  }
}
