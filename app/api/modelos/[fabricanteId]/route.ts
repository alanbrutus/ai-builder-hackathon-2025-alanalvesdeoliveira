import { NextResponse } from 'next/server';
import { executeStoredProcedure } from '@/lib/db';

export interface Modelo {
  Id: number;
  Nome: string;
  AnoInicio: number;
  AnoFim: number | null;
  TipoVeiculo: string;
  Periodo: string;
}

export async function GET(
  request: Request,
  { params }: { params: { fabricanteId: string } }
) {
  try {
    const fabricanteId = parseInt(params.fabricanteId);

    if (isNaN(fabricanteId)) {
      return NextResponse.json(
        {
          success: false,
          error: 'ID do fabricante inválido',
        },
        { status: 400 }
      );
    }

    const modelos = await executeStoredProcedure<Modelo>(
      'AIHT_sp_ListarModelosPorFabricante',
      { FabricanteId: fabricanteId }
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
