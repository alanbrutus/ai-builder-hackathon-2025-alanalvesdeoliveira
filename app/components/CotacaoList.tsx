import React from 'react';
import CotacaoCard from './CotacaoCard';

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

interface CotacaoListProps {
  pecas: Peca[];
  titulo?: string;
  mensagemVazia?: string;
}

export default function CotacaoList({ 
  pecas, 
  titulo = '💰 Cotação de Peças',
  mensagemVazia = 'Nenhuma peça identificada ainda.'
}: CotacaoListProps) {
  
  if (!pecas || pecas.length === 0) {
    return (
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-6 text-center">
        <div className="text-4xl mb-3">📦</div>
        <p className="text-gray-600">{mensagemVazia}</p>
      </div>
    );
  }

  const calcularTotalEstimado = () => {
    // Valores estimados baseados em categoria
    const precosPorCategoria: { [key: string]: { min: number; max: number } } = {
      'freio': { min: 150, max: 300 },
      'suspensão': { min: 200, max: 500 },
      'motor': { min: 300, max: 800 },
      'elétrica': { min: 100, max: 400 },
      'filtro': { min: 30, max: 80 },
      'óleo': { min: 50, max: 150 },
      'pneu': { min: 300, max: 600 },
      'bateria': { min: 250, max: 500 },
      'default': { min: 100, max: 300 }
    };

    let totalMin = 0;
    let totalMax = 0;

    pecas.forEach(peca => {
      const categoria = peca.CategoriaPeca?.toLowerCase() || 'default';
      const precos = precosPorCategoria[categoria] || precosPorCategoria['default'];
      totalMin += precos.min;
      totalMax += precos.max;
    });

    return { totalMin, totalMax };
  };

  const { totalMin, totalMax } = calcularTotalEstimado();

  const formatPreco = (valor: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor);
  };

  const getDicaPorCategoria = (categoria?: string): string => {
    const dicas: { [key: string]: string } = {
      'freio': 'Sempre prefira peças originais para segurança. Verifique se vem com certificação.',
      'suspensão': 'Troque sempre em pares (ambos os lados) para manter o equilíbrio.',
      'motor': 'Peças de motor exigem instalação profissional. Consulte um mecânico.',
      'elétrica': 'Verifique a voltagem correta para seu veículo (12V ou 24V).',
      'filtro': 'Troque regularmente conforme manual do fabricante.',
      'óleo': 'Use sempre a viscosidade recomendada pelo fabricante.',
      'pneu': 'Verifique índice de carga e velocidade compatíveis.',
      'bateria': 'Verifique amperagem (Ah) compatível com seu veículo.',
      'default': 'Prefira peças com garantia e de fornecedores confiáveis.'
    };

    const cat = categoria?.toLowerCase() || 'default';
    return dicas[cat] || dicas['default'];
  };

  const getPrecoPorCategoria = (categoria?: string): { min: number; max: number } => {
    const precos: { [key: string]: { min: number; max: number } } = {
      'freio': { min: 150, max: 300 },
      'suspensão': { min: 200, max: 500 },
      'motor': { min: 300, max: 800 },
      'elétrica': { min: 100, max: 400 },
      'filtro': { min: 30, max: 80 },
      'óleo': { min: 50, max: 150 },
      'pneu': { min: 300, max: 600 },
      'bateria': { min: 250, max: 500 },
      'default': { min: 100, max: 300 }
    };

    const cat = categoria?.toLowerCase() || 'default';
    return precos[cat] || precos['default'];
  };

  return (
    <div className="space-y-3">
      {/* Cabeçalho Compacto */}
      <div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-lg p-3 shadow-sm">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-base font-bold">{titulo}</h2>
            <p className="text-xs opacity-90 mt-0.5">{pecas.length} peças identificadas</p>
          </div>
          <div className="text-right">
            <p className="text-xs opacity-90">Total estimado</p>
            <p className="text-sm font-bold">
              {formatPreco(totalMin)} - {formatPreco(totalMax)}
            </p>
          </div>
        </div>
      </div>

      {/* Grid de Peças - 3 colunas para melhor aproveitamento */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
        {pecas.map((peca) => {
          const precos = getPrecoPorCategoria(peca.CategoriaPeca);
          const dica = getDicaPorCategoria(peca.CategoriaPeca);
          
          return (
            <CotacaoCard
              key={peca.PecaId}
              peca={peca}
              precoMinimo={precos.min}
              precoMaximo={precos.max}
              dica={dica}
            />
          );
        })}
      </div>

      {/* Rodapé Compacto */}
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-2.5">
        <div className="flex items-start gap-2">
          <span className="text-lg flex-shrink-0">⚠️</span>
          <div className="text-xs text-yellow-800">
            <p className="font-medium mb-1">Preços estimados - Consulte fornecedores</p>
            <p className="text-yellow-700">
              Valores variam por fabricante, região e disponibilidade. 
              Sempre verifique compatibilidade e peça nota fiscal.
            </p>
          </div>
        </div>
      </div>

      {/* Botões de Ação Compactos */}
      <div className="flex gap-2">
        <button
          onClick={() => window.print()}
          className="flex-1 px-3 py-2 bg-gray-600 hover:bg-gray-700 text-white text-sm font-medium rounded-lg transition-colors flex items-center justify-center gap-1.5"
        >
          <span>🖨️</span>
          <span>Imprimir</span>
        </button>
        
        <button
          onClick={() => {
            const texto = pecas.map(p => 
              `${p.NomePeca}${p.CodigoPeca ? ` (${p.CodigoPeca})` : ''}`
            ).join('\n');
            navigator.clipboard.writeText(texto);
            alert('Lista copiada!');
          }}
          className="flex-1 px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors flex items-center justify-center gap-1.5"
        >
          <span>📋</span>
          <span>Copiar</span>
        </button>
      </div>
    </div>
  );
}
