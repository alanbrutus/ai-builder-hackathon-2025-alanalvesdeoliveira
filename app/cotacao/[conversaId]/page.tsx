"use client";

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import CotacaoList from '@/app/components/CotacaoList';

interface Peca {
  PecaId: number;
  NomePeca: string;
  CodigoPeca?: string;
  CategoriaPeca?: string;
  Prioridade?: string;
  DescricaoProblema?: string;
  ModeloVeiculo?: string;
  MarcaVeiculo?: string;
}

interface Conversa {
  ConversaId: number;
  NomeCliente: string;
  DataInicio: string;
  GrupoEmpresarial?: string;
  MarcaVeiculo?: string;
  ModeloVeiculo?: string;
}

export default function CotacaoPage() {
  const params = useParams();
  const router = useRouter();
  const conversaId = params.conversaId as string;

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [conversa, setConversa] = useState<Conversa | null>(null);
  const [pecas, setPecas] = useState<Peca[]>([]);

  useEffect(() => {
    if (conversaId) {
      carregarCotacao();
    }
  }, [conversaId]);

  const carregarCotacao = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await fetch(`/api/resumo-cotacao/${conversaId}`);
      const data = await response.json();

      if (data.success) {
        setConversa(data.conversa);
        setPecas(data.pecas || []);
      } else {
        setError(data.error || 'Erro ao carregar cotação');
      }
    } catch (err: any) {
      console.error('Erro ao carregar cotação:', err);
      setError('Erro ao carregar cotação. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
          <p className="text-gray-600">Carregando cotação...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="bg-white border border-red-200 rounded-lg p-6 max-w-md w-full">
          <div className="text-center">
            <div className="text-4xl mb-4">❌</div>
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              Erro ao Carregar Cotação
            </h2>
            <p className="text-gray-600 mb-4">{error}</p>
            <div className="flex gap-3">
              <button
                onClick={() => router.back()}
                className="flex-1 px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-md transition-colors"
              >
                Voltar
              </button>
              <button
                onClick={carregarCotacao}
                className="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md transition-colors"
              >
                Tentar Novamente
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header Compacto */}
      <div className="bg-white border-b border-gray-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            <div className="flex-1 min-w-0">
              <Link 
                href="/chat"
                className="text-blue-600 hover:text-blue-700 text-xs font-medium inline-block mb-1"
              >
                ← Voltar
              </Link>
              <h1 className="text-lg font-bold text-gray-900">
                💰 Cotação de Peças
              </h1>
              {conversa && (
                <p className="text-xs text-gray-600 mt-0.5 truncate">
                  {conversa.NomeCliente} • {conversa.MarcaVeiculo} {conversa.ModeloVeiculo}
                </p>
              )}
            </div>
            
            <div className="flex gap-2 ml-4">
              <button
                onClick={() => window.print()}
                className="px-3 py-1.5 bg-gray-600 hover:bg-gray-700 text-white text-xs rounded-md transition-colors"
                title="Imprimir"
              >
                🖨️
              </button>
              
              <button
                onClick={() => {
                  const texto = pecas.map(p => 
                    `${p.NomePeca}${p.CodigoPeca ? ` (${p.CodigoPeca})` : ''}`
                  ).join('\n');
                  navigator.clipboard.writeText(texto);
                  alert('Lista copiada!');
                }}
                className="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs rounded-md transition-colors"
                title="Copiar lista"
              >
                📋
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 py-4">
        <CotacaoList 
          pecas={pecas}
          titulo="💰 Peças Identificadas"
          mensagemVazia="Nenhuma peça identificada ainda."
        />
      </div>
    </div>
  );
}
