import { NextResponse } from 'next/server';
import { executeStoredProcedure } from '@/lib/db';

export interface Prompt {
  Id: number;
  Nome: string;
  Descricao: string;
  Contexto: string;
  ConteudoPrompt: string;
  Variaveis: string;
  Ativo: boolean;
  Versao: number;
  DataCriacao: string;
  DataAtualizacao: string;
  CriadoPor: string;
  AtualizadoPor: string;
}

// Listar todos os prompts
export async function GET() {
  try {
    const prompts = await executeStoredProcedure<Prompt>(
      'AIHT_sp_ListarPrompts',
      { ApenasAtivos: 1 }
    );

    return NextResponse.json({
      success: true,
      data: prompts,
    });
  } catch (error) {
    console.error('Erro ao listar prompts:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro ao listar prompts',
      },
      { status: 500 }
    );
  }
}

// Atualizar prompt
export async function PUT(request: Request) {
  try {
    const body = await request.json();
    const { id, conteudoPrompt, atualizadoPor } = body;

    if (!id || !conteudoPrompt) {
      return NextResponse.json(
        {
          success: false,
          error: 'ID e conteúdo do prompt são obrigatórios',
        },
        { status: 400 }
      );
    }

    const result = await executeStoredProcedure(
      'AIHT_sp_AtualizarPrompt',
      {
        Id: id,
        ConteudoPrompt: conteudoPrompt,
        AtualizadoPor: atualizadoPor || 'Sistema',
      }
    );

    return NextResponse.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('Erro ao atualizar prompt:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro ao atualizar prompt',
      },
      { status: 500 }
    );
  }
}

// Criar novo prompt
export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { nome, descricao, contexto, conteudoPrompt, variaveis, criadoPor } = body;

    if (!nome || !contexto || !conteudoPrompt) {
      return NextResponse.json(
        {
          success: false,
          error: 'Nome, contexto e conteúdo são obrigatórios',
        },
        { status: 400 }
      );
    }

    const result = await executeStoredProcedure(
      'AIHT_sp_CriarPrompt',
      {
        Nome: nome,
        Descricao: descricao || '',
        Contexto: contexto,
        ConteudoPrompt: conteudoPrompt,
        Variaveis: variaveis || '[]',
        CriadoPor: criadoPor || 'Sistema',
      }
    );

    return NextResponse.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('Erro ao criar prompt:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro ao criar prompt',
      },
      { status: 500 }
    );
  }
}
