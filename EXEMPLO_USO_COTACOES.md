# 📝 Exemplo de Uso do Sistema de Cotações

## 🎯 Fluxo Completo de Integração

### 1. Cliente Solicita Cotação

```typescript
// No componente de chat
const handleEnviarMensagem = async (mensagem: string) => {
  // Verificar se é uma solicitação de cotação
  const response = await fetch('/api/gerar-cotacao', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      conversaId: conversaAtual.id,
      mensagemCliente: mensagem
    })
  });

  const data = await response.json();

  if (data.intencaoCotacao && data.cotacao) {
    // Parsear e salvar cotações
    await salvarCotacoes(data.cotacao, data.pecas, conversaAtual.id);
  }
};
```

### 2. Parsear Resposta da IA

```typescript
interface CotacaoParsed {
  nomePeca: string;
  tipoCotacao: 'E-Commerce' | 'Loja Física';
  link?: string;
  endereco?: string;
  nomeLoja?: string;
  telefone?: string;
  preco?: number;
  precoMinimo?: number;
  precoMaximo?: number;
  condicoesPagamento?: string;
  observacoes?: string;
  disponibilidade?: string;
  prazoEntrega?: string;
  estadoPeca?: 'Nova' | 'Usada' | 'Recondicionada';
}

function parsearCotacaoIA(respostaIA: string): CotacaoParsed[] {
  const cotacoes: CotacaoParsed[] = [];
  
  // Exemplo de parsing (ajustar conforme formato da IA)
  const linhas = respostaIA.split('\n');
  let cotacaoAtual: Partial<CotacaoParsed> = {};
  
  for (const linha of linhas) {
    // Detectar início de nova peça
    if (linha.includes('Peça:') || linha.includes('🔧')) {
      if (cotacaoAtual.nomePeca) {
        cotacoes.push(cotacaoAtual as CotacaoParsed);
      }
      cotacaoAtual = {
        nomePeca: extrairNomePeca(linha)
      };
    }
    
    // Detectar tipo
    if (linha.includes('E-Commerce') || linha.includes('🛒')) {
      cotacaoAtual.tipoCotacao = 'E-Commerce';
    } else if (linha.includes('Loja Física') || linha.includes('🏪')) {
      cotacaoAtual.tipoCotacao = 'Loja Física';
    }
    
    // Detectar link
    if (linha.includes('http://') || linha.includes('https://')) {
      cotacaoAtual.link = extrairLink(linha);
    }
    
    // Detectar endereço
    if (linha.includes('Endereço:')) {
      cotacaoAtual.endereco = extrairEndereco(linha);
    }
    
    // Detectar preço
    if (linha.includes('R$') || linha.includes('Preço:')) {
      const precos = extrairPreco(linha);
      if (precos.unico) {
        cotacaoAtual.preco = precos.unico;
      } else {
        cotacaoAtual.precoMinimo = precos.minimo;
        cotacaoAtual.precoMaximo = precos.maximo;
      }
    }
    
    // Detectar condições de pagamento
    if (linha.includes('Pagamento:') || linha.includes('💳')) {
      cotacaoAtual.condicoesPagamento = extrairCondicoesPagamento(linha);
    }
    
    // Detectar estado da peça
    if (linha.includes('Nova') || linha.includes('🆕')) {
      cotacaoAtual.estadoPeca = 'Nova';
    } else if (linha.includes('Usada') || linha.includes('♻️')) {
      cotacaoAtual.estadoPeca = 'Usada';
    } else if (linha.includes('Recondicionada')) {
      cotacaoAtual.estadoPeca = 'Recondicionada';
    }
    
    // Detectar disponibilidade
    if (linha.includes('Disponibilidade:') || linha.includes('📦')) {
      cotacaoAtual.disponibilidade = extrairDisponibilidade(linha);
    }
    
    // Detectar prazo de entrega
    if (linha.includes('Entrega:') || linha.includes('🚚')) {
      cotacaoAtual.prazoEntrega = extrairPrazoEntrega(linha);
    }
  }
  
  // Adicionar última cotação
  if (cotacaoAtual.nomePeca) {
    cotacoes.push(cotacaoAtual as CotacaoParsed);
  }
  
  return cotacoes;
}

// Funções auxiliares de extração
function extrairNomePeca(linha: string): string {
  return linha.replace(/.*(?:Peça:|🔧)\s*/i, '').trim();
}

function extrairLink(linha: string): string {
  const match = linha.match(/(https?:\/\/[^\s]+)/);
  return match ? match[1] : '';
}

function extrairEndereco(linha: string): string {
  return linha.replace(/.*Endereço:\s*/i, '').trim();
}

function extrairPreco(linha: string): { unico?: number; minimo?: number; maximo?: number } {
  // Detectar faixa de preço: R$ 150,00 - R$ 200,00
  const faixaMatch = linha.match(/R\$\s*([\d.,]+)\s*-\s*R\$\s*([\d.,]+)/);
  if (faixaMatch) {
    return {
      minimo: parseFloat(faixaMatch[1].replace(',', '.')),
      maximo: parseFloat(faixaMatch[2].replace(',', '.'))
    };
  }
  
  // Detectar preço único: R$ 189,90
  const unicoMatch = linha.match(/R\$\s*([\d.,]+)/);
  if (unicoMatch) {
    return {
      unico: parseFloat(unicoMatch[1].replace(',', '.'))
    };
  }
  
  return {};
}

function extrairCondicoesPagamento(linha: string): string {
  return linha.replace(/.*(?:Pagamento:|💳)\s*/i, '').trim();
}

function extrairDisponibilidade(linha: string): string {
  return linha.replace(/.*(?:Disponibilidade:|📦)\s*/i, '').trim();
}

function extrairPrazoEntrega(linha: string): string {
  return linha.replace(/.*(?:Entrega:|🚚)\s*/i, '').trim();
}
```

### 3. Salvar Cotações no Banco

```typescript
async function salvarCotacoes(
  respostaIA: string,
  pecas: any[],
  conversaId: number
) {
  try {
    // Parsear resposta da IA
    const cotacoesParsed = parsearCotacaoIA(respostaIA);
    
    // Mapear para o formato da API
    const cotacoes = cotacoesParsed.map(cotacao => {
      // Encontrar peça correspondente
      const peca = pecas.find(p => 
        p.NomePeca.toLowerCase().includes(cotacao.nomePeca.toLowerCase())
      );
      
      if (!peca) {
        console.warn(`Peça não encontrada: ${cotacao.nomePeca}`);
        return null;
      }
      
      return {
        conversaId,
        problemaId: peca.ProblemaId,
        pecaIdentificadaId: peca.Id,
        nomePeca: cotacao.nomePeca,
        tipoCotacao: cotacao.tipoCotacao,
        link: cotacao.link,
        endereco: cotacao.endereco,
        nomeLoja: cotacao.nomeLoja,
        telefone: cotacao.telefone,
        preco: cotacao.preco,
        precoMinimo: cotacao.precoMinimo,
        precoMaximo: cotacao.precoMaximo,
        condicoesPagamento: cotacao.condicoesPagamento,
        observacoes: cotacao.observacoes,
        disponibilidade: cotacao.disponibilidade,
        prazoEntrega: cotacao.prazoEntrega,
        estadoPeca: cotacao.estadoPeca
      };
    }).filter(c => c !== null);
    
    // Salvar no banco
    const response = await fetch('/api/salvar-cotacao', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cotacoes })
    });
    
    const result = await response.json();
    
    if (result.success) {
      console.log(`✅ ${result.totalSalvas} cotações salvas com sucesso`);
      return result.cotacoes;
    } else {
      console.error('❌ Erro ao salvar cotações:', result.error);
      return [];
    }
  } catch (error) {
    console.error('❌ Erro ao processar cotações:', error);
    return [];
  }
}
```

### 4. Exibir Cotações Salvas

```typescript
// Componente para exibir cotações
import { useEffect, useState } from 'react';

interface CotacaoExibicao {
  Id: number;
  NomePeca: string;
  TipoCotacao: string;
  Link?: string;
  Endereco?: string;
  NomeLoja?: string;
  Preco?: number;
  PrecoMinimo?: number;
  PrecoMaximo?: number;
  CondicoesPagamento?: string;
  Observacoes?: string;
  EstadoPeca?: string;
}

export function CotacoesSalvas({ conversaId }: { conversaId: number }) {
  const [cotacoes, setCotacoes] = useState<CotacaoExibicao[]>([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    carregarCotacoes();
  }, [conversaId]);
  
  async function carregarCotacoes() {
    try {
      const response = await fetch(`/api/cotacoes/${conversaId}`);
      const data = await response.json();
      
      if (data.success) {
        setCotacoes(data.cotacoes);
      }
    } catch (error) {
      console.error('Erro ao carregar cotações:', error);
    } finally {
      setLoading(false);
    }
  }
  
  if (loading) {
    return <div>Carregando cotações...</div>;
  }
  
  if (cotacoes.length === 0) {
    return <div>Nenhuma cotação encontrada</div>;
  }
  
  return (
    <div className="space-y-4">
      <h3 className="text-lg font-bold">Cotações Salvas</h3>
      
      {cotacoes.map(cotacao => (
        <div key={cotacao.Id} className="border rounded-lg p-4">
          <div className="flex justify-between items-start">
            <div>
              <h4 className="font-semibold">{cotacao.NomePeca}</h4>
              <span className="text-sm text-gray-600">
                {cotacao.TipoCotacao}
              </span>
            </div>
            
            <div className="text-right">
              {cotacao.Preco ? (
                <span className="text-lg font-bold text-green-600">
                  R$ {cotacao.Preco.toFixed(2)}
                </span>
              ) : cotacao.PrecoMinimo && cotacao.PrecoMaximo ? (
                <span className="text-lg font-bold text-green-600">
                  R$ {cotacao.PrecoMinimo.toFixed(2)} - R$ {cotacao.PrecoMaximo.toFixed(2)}
                </span>
              ) : (
                <span className="text-gray-500">Preço não informado</span>
              )}
            </div>
          </div>
          
          {cotacao.TipoCotacao === 'E-Commerce' && cotacao.Link && (
            <a 
              href={cotacao.Link} 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline text-sm"
            >
              Ver no site →
            </a>
          )}
          
          {cotacao.TipoCotacao === 'Loja Física' && (
            <div className="mt-2 text-sm">
              {cotacao.NomeLoja && <div>🏪 {cotacao.NomeLoja}</div>}
              {cotacao.Endereco && <div>📍 {cotacao.Endereco}</div>}
            </div>
          )}
          
          {cotacao.CondicoesPagamento && (
            <div className="mt-2 text-sm text-gray-600">
              💳 {cotacao.CondicoesPagamento}
            </div>
          )}
          
          {cotacao.EstadoPeca && (
            <span className="inline-block mt-2 px-2 py-1 text-xs rounded bg-gray-100">
              {cotacao.EstadoPeca}
            </span>
          )}
        </div>
      ))}
    </div>
  );
}
```

### 5. Resumo Estatístico

```typescript
export function ResumoCotacoes({ conversaId }: { conversaId: number }) {
  const [resumo, setResumo] = useState<any>(null);
  
  useEffect(() => {
    carregarResumo();
  }, [conversaId]);
  
  async function carregarResumo() {
    try {
      const response = await fetch(`/api/cotacoes/resumo/${conversaId}`);
      const data = await response.json();
      
      if (data.success) {
        setResumo(data);
      }
    } catch (error) {
      console.error('Erro ao carregar resumo:', error);
    }
  }
  
  if (!resumo) return null;
  
  const { resumoGeral, resumoPorPeca } = resumo;
  
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-blue-50 p-4 rounded">
          <div className="text-2xl font-bold">{resumoGeral.TotalCotacoes}</div>
          <div className="text-sm text-gray-600">Total de Cotações</div>
        </div>
        
        <div className="bg-green-50 p-4 rounded">
          <div className="text-2xl font-bold">{resumoGeral.CotacoesECommerce}</div>
          <div className="text-sm text-gray-600">E-Commerce</div>
        </div>
        
        <div className="bg-purple-50 p-4 rounded">
          <div className="text-2xl font-bold">{resumoGeral.CotacoesLojaFisica}</div>
          <div className="text-sm text-gray-600">Lojas Físicas</div>
        </div>
      </div>
      
      {resumoGeral.MenorPreco && (
        <div className="bg-gray-50 p-4 rounded">
          <div className="flex justify-between">
            <div>
              <div className="text-sm text-gray-600">Menor Preço</div>
              <div className="text-xl font-bold text-green-600">
                R$ {resumoGeral.MenorPreco.toFixed(2)}
              </div>
            </div>
            
            <div>
              <div className="text-sm text-gray-600">Maior Preço</div>
              <div className="text-xl font-bold text-red-600">
                R$ {resumoGeral.MaiorPreco.toFixed(2)}
              </div>
            </div>
            
            <div>
              <div className="text-sm text-gray-600">Preço Médio</div>
              <div className="text-xl font-bold text-blue-600">
                R$ {resumoGeral.PrecoMedio.toFixed(2)}
              </div>
            </div>
          </div>
        </div>
      )}
      
      <div>
        <h4 className="font-semibold mb-2">Cotações por Peça</h4>
        <div className="space-y-2">
          {resumoPorPeca.map((peca: any) => (
            <div key={peca.PecaIdentificadaId} className="flex justify-between items-center p-2 bg-gray-50 rounded">
              <span>{peca.NomePeca}</span>
              <div className="text-sm">
                <span className="font-semibold">{peca.QuantidadeCotacoes}</span> cotações
                {peca.MenorPreco && (
                  <span className="ml-2 text-green-600">
                    R$ {peca.MenorPreco.toFixed(2)} - R$ {peca.MaiorPreco.toFixed(2)}
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
```

## 🔄 Fluxo Completo Integrado

```typescript
// Exemplo de uso completo no componente de chat
export default function ChatPage() {
  const [conversaId, setConversaId] = useState<number | null>(null);
  const [mostrarCotacoes, setMostrarCotacoes] = useState(false);
  
  const handleSolicitarCotacao = async (mensagem: string) => {
    // 1. Gerar cotação via IA
    const response = await fetch('/api/gerar-cotacao', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        conversaId,
        mensagemCliente: mensagem
      })
    });
    
    const data = await response.json();
    
    if (data.success && data.intencaoCotacao) {
      // 2. Salvar cotações parseadas
      await salvarCotacoes(data.cotacao, data.pecas, conversaId!);
      
      // 3. Exibir cotações salvas
      setMostrarCotacoes(true);
    }
  };
  
  return (
    <div>
      {/* Chat normal */}
      <ChatInterface onEnviarMensagem={handleSolicitarCotacao} />
      
      {/* Cotações salvas */}
      {mostrarCotacoes && conversaId && (
        <div className="mt-4">
          <ResumoCotacoes conversaId={conversaId} />
          <CotacoesSalvas conversaId={conversaId} />
        </div>
      )}
    </div>
  );
}
```

## ✅ Checklist de Implementação

- [x] Criar tabela `AIHT_CotacoesPecas`
- [x] Criar stored procedures
- [x] Criar APIs REST
- [ ] Implementar parser de resposta da IA
- [ ] Integrar com `/api/gerar-cotacao`
- [ ] Criar componentes React para exibição
- [ ] Adicionar testes automatizados
- [ ] Documentar formato esperado da IA

---

**Nota**: O parser de resposta da IA precisa ser ajustado conforme o formato real retornado pelo Gemini Pro. Este é um exemplo genérico que deve ser adaptado.
