import React from 'react';

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

interface CotacaoCardProps {
  peca: Peca;
  precoMinimo?: number;
  precoMaximo?: number;
  linkMercadoLivre?: string;
  linkOLX?: string;
  dica?: string;
}

export default function CotacaoCard({ 
  peca, 
  precoMinimo, 
  precoMaximo,
  linkMercadoLivre,
  linkOLX,
  dica 
}: CotacaoCardProps) {
  
  const getPrioridadeColor = (prioridade?: string) => {
    switch (prioridade?.toLowerCase()) {
      case 'alta':
      case 'urgente':
        return 'bg-red-100 text-red-700 border-red-300';
      case 'média':
      case 'media':
        return 'bg-yellow-100 text-yellow-700 border-yellow-300';
      case 'baixa':
        return 'bg-green-100 text-green-700 border-green-300';
      default:
        return 'bg-gray-100 text-gray-700 border-gray-300';
    }
  };

  const formatPreco = (valor?: number) => {
    if (!valor) return 'Consultar';
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor);
  };

  const gerarLinkMercadoLivre = () => {
    if (linkMercadoLivre) return linkMercadoLivre;
    const query = encodeURIComponent(
      `${peca.NomePeca} ${peca.MarcaVeiculo || ''} ${peca.ModeloVeiculo || ''}`
    );
    return `https://lista.mercadolivre.com.br/${query}`;
  };

  const gerarLinkOLX = () => {
    if (linkOLX) return linkOLX;
    const query = encodeURIComponent(peca.NomePeca);
    return `https://www.olx.com.br/brasil?q=${query}`;
  };

  const gerarLinkGoogle = () => {
    const query = encodeURIComponent(
      `${peca.NomePeca} ${peca.CodigoPeca || ''} preço`
    );
    return `https://www.google.com/search?q=${query}`;
  };

  return (
    <div className="bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow p-3">
      {/* Cabeçalho Compacto */}
      <div className="flex items-start justify-between mb-2">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-1.5">
            <span className="text-lg">🔧</span>
            <h3 className="text-sm font-semibold text-gray-900 truncate">
              {peca.NomePeca}
            </h3>
          </div>
          <div className="flex items-center gap-2 mt-0.5">
            {peca.CodigoPeca && (
              <span className="text-xs text-gray-600 font-mono">{peca.CodigoPeca}</span>
            )}
            {peca.CategoriaPeca && (
              <span className="text-xs text-gray-500">• {peca.CategoriaPeca}</span>
            )}
          </div>
        </div>
        {peca.Prioridade && (
          <span className={`px-1.5 py-0.5 text-xs font-medium rounded border ${getPrioridadeColor(peca.Prioridade)}`}>
            {peca.Prioridade}
          </span>
        )}
      </div>

      {/* Preços Compacto */}
      {(precoMinimo || precoMaximo) && (
        <div className="mb-2 p-2 bg-green-50 border border-green-200 rounded">
          <div className="flex items-center justify-between text-xs">
            <div>
              <span className="text-green-700">Min: </span>
              <span className="font-bold text-green-900">{formatPreco(precoMinimo)}</span>
            </div>
            <span className="text-gray-400">→</span>
            <div>
              <span className="text-green-700">Max: </span>
              <span className="font-bold text-green-900">{formatPreco(precoMaximo)}</span>
            </div>
          </div>
        </div>
      )}

      {/* Botões Compactos */}
      <div className="flex gap-1.5">
        <a
          href={gerarLinkMercadoLivre()}
          target="_blank"
          rel="noopener noreferrer"
          className="flex-1 px-2 py-1.5 bg-yellow-400 hover:bg-yellow-500 text-yellow-900 text-xs font-medium rounded text-center transition-colors"
          title="Buscar no Mercado Livre"
        >
          🛒 ML
        </a>
        <a
          href={gerarLinkOLX()}
          target="_blank"
          rel="noopener noreferrer"
          className="flex-1 px-2 py-1.5 bg-purple-500 hover:bg-purple-600 text-white text-xs font-medium rounded text-center transition-colors"
          title="Buscar no OLX"
        >
          🔍 OLX
        </a>
        <a
          href={gerarLinkGoogle()}
          target="_blank"
          rel="noopener noreferrer"
          className="flex-1 px-2 py-1.5 bg-blue-500 hover:bg-blue-600 text-white text-xs font-medium rounded text-center transition-colors"
          title="Buscar no Google"
        >
          🌐 Google
        </a>
      </div>
    </div>
  );
}
