import { NextResponse } from 'next/server';
import { executeStoredProcedure } from '@/lib/db';

export interface GrupoEmpresarial {
  Id: number;
  Nome: string;
  Descricao: string;
  PaisOrigem: string;
  AnoFundacao: number;
  TotalFabricantes: number;
  TotalModelos: number;
}

export async function GET() {
  try {
    const grupos = await executeStoredProcedure<GrupoEmpresarial>(
      'AIHT_sp_ListarGruposEmpresariais'
    );

    return NextResponse.json({
      success: true,
      data: grupos,
    });
  } catch (error) {
    console.error('Erro ao buscar grupos:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro ao buscar grupos empresariais',
      },
      { status: 500 }
    );
  }
}
