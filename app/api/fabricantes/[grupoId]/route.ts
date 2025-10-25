import { NextResponse } from 'next/server';
import { executeStoredProcedure } from '@/lib/db';

export interface Fabricante {
  Id: number;
  Nome: string;
  Pais: string;
  TotalModelos: number;
}

export async function GET(
  request: Request,
  { params }: { params: { grupoId: string } }
) {
  try {
    const grupoId = parseInt(params.grupoId);

    if (isNaN(grupoId)) {
      return NextResponse.json(
        {
          success: false,
          error: 'ID do grupo inválido',
        },
        { status: 400 }
      );
    }

    const fabricantes = await executeStoredProcedure<Fabricante>(
      'AIHT_sp_ListarFabricantesPorGrupo',
      { GrupoEmpresarialId: grupoId }
    );

    return NextResponse.json({
      success: true,
      data: fabricantes,
    });
  } catch (error) {
    console.error('Erro ao buscar fabricantes:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro ao buscar fabricantes',
      },
      { status: 500 }
    );
  }
}
