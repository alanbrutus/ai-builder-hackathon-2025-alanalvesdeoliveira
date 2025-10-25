import { NextResponse } from 'next/server';
import { executeStoredProcedure } from '@/lib/db';

export interface Prompt {
  Id: number;
  Nome: string;
  Descricao: string;
  Contexto: string;
  ConteudoPrompt: string;
  Variaveis: string;
  Versao: number;
  DataAtualizacao: string;
}

export async function GET(
  request: Request,
  { params }: { params: { contexto: string } }
) {
  try {
    const contexto = params.contexto;

    const prompts = await executeStoredProcedure<Prompt>(
      'AIHT_sp_BuscarPromptPorContexto',
      { Contexto: contexto }
    );

    if (prompts.length === 0) {
      return NextResponse.json(
        {
          success: false,
          error: 'Prompt não encontrado para este contexto',
        },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: prompts[0],
    });
  } catch (error) {
    console.error('Erro ao buscar prompt:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro ao buscar prompt',
      },
      { status: 500 }
    );
  }
}
