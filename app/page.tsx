'use client';

import { useState, useRef, useEffect } from 'react';
import { Send, Car, Wrench, Package, Settings, User, MessageSquare } from 'lucide-react';

type Message = {
  id: string;
  content: string;
  isUser: boolean;
  timestamp: Date;
};

type ProductSuggestion = {
  id: string;
  name: string;
  price: number;
  image: string;
  category: string;
};

export default function Home() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [suggestedProducts, setSuggestedProducts] = useState<ProductSuggestion[]>([]);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Mensagem de boas-vindas inicial
  useEffect(() => {
    const welcomeMessage: Message = {
      id: '1',
      content: 'Olá! Sou o assistente virtual da AutoParts AI. Como posso ajudar você hoje? Posso auxiliar na busca por peças de reposição, acessórios de tuning e muito mais para o seu veículo.',
      isUser: false,
      timestamp: new Date(),
    };
    setMessages([welcomeMessage]);
  }, []);

  // Rolar para a última mensagem
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!input.trim()) return;

    // Adiciona a mensagem do usuário
    const userMessage: Message = {
      id: Date.now().toString(),
      content: input,
      isUser: true,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      // Simula uma resposta da IA
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Resposta simulada baseada na entrada do usuário
      let responseText = '';
      const lowerInput = input.toLowerCase();
      
      if (lowerInput.includes('preço') || lowerInput.includes('quanto custa')) {
        responseText = 'Posso ajudar a encontrar o preço de várias peças. Você poderia especificar qual peça está procurando? Por exemplo: "Quanto custa um filtro de ar para Onix 2020?"';
      } else if (lowerInput.includes('disponível') || lowerInput.includes('tem em estoque')) {
        responseText = 'Verificando nossa base de dados...';
        
        // Simula produtos sugeridos
        setTimeout(() => {
          setSuggestedProducts([
            {
              id: '1',
              name: 'Kit Amortecedor Dianteiro Completo',
              price: 1299.90,
              image: 'https://via.placeholder.com/100',
              category: 'Suspensão'
            },
            {
              id: '2',
              name: 'Pastilha de Freio Dianteira',
              price: 189.90,
              image: 'https://via.placeholder.com/100',
              category: 'Freios'
            },
            {
              id: '3',
              name: 'Filtro de Ar Esportivo',
              price: 349.90,
              image: 'https://via.placeholder.com/100',
              category: 'Performance'
            }
          ]);
        }, 500);
      } else if (lowerInput.includes('ajuda') || lowerInput.includes('como funciona')) {
        responseText = 'Posso te ajudar com:\n- Busca de peças por modelo de veículo\n- Verificação de compatibilidade\n- Orçamento de serviços\n- Acompanhamento de pedidos\n\nComo posso te ajudar hoje?';
      } else {
        responseText = 'Entendi sua solicitação. Estou verificando as melhores opções para você. Poderia me informar o modelo e ano do seu veículo para que eu possa te ajudar melhor?';
      }
      
      const botMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: responseText,
        isUser: false,
        timestamp: new Date(),
      };
      
      setMessages(prev => [...prev, botMessage]);
    } catch (error) {
      console.error('Erro ao enviar mensagem:', error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: 'Desculpe, ocorreu um erro ao processar sua solicitação. Por favor, tente novamente mais tarde.',
        isUser: false,
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleQuickQuestion = (question: string) => {
    setInput(question);
  };

  return (
    <div className="flex flex-col h-[calc(100vh-200px)] max-w-4xl mx-auto p-4">
      <div className="mb-6 text-center">
        <h1 className="text-3xl font-bold text-blue-600 mb-2">AutoParts AI</h1>
        <p className="text-gray-600">Seu assistente virtual para peças automotivas e tuning</p>
      </div>
      
      <div className="flex-1 overflow-y-auto mb-6 space-y-4 p-4 bg-white rounded-lg shadow">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${message.isUser ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[80%] p-3 rounded-lg ${
                message.isUser
                  ? 'bg-blue-500 text-white rounded-br-none'
                  : 'bg-gray-100 text-gray-800 rounded-bl-none'
              }`}
            >
              <p className="whitespace-pre-line">{message.content}</p>
              <p className="text-xs mt-1 opacity-70">
                {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
              </p>
            </div>
          </div>
        ))}
        
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-gray-100 p-3 rounded-lg rounded-bl-none max-w-[80%]">
              <div className="flex space-x-2">
                <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce" style={{ animationDelay: '0ms' }}></div>
                <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce" style={{ animationDelay: '150ms' }}></div>
                <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce" style={{ animationDelay: '300ms' }}></div>
              </div>
            </div>
          </div>
        )}
        
        {suggestedProducts.length > 0 && (
          <div className="mt-6">
            <h3 className="text-lg font-semibold mb-3">Produtos que podem te interessar:</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {suggestedProducts.map((product) => (
                <div key={product.id} className="border rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                  <div className="bg-gray-100 h-32 flex items-center justify-center">
                    <img src={product.image} alt={product.name} className="h-full object-cover" />
                  </div>
                  <div className="p-3">
                    <span className="text-xs text-blue-600 font-medium">{product.category}</span>
                    <h4 className="font-medium text-sm mt-1">{product.name}</h4>
                    <p className="text-lg font-bold text-gray-900 mt-2">
                      {product.price.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}
                    </p>
                    <button className="mt-2 w-full bg-blue-500 hover:bg-blue-600 text-white text-sm py-1 px-3 rounded transition-colors">
                      Ver detalhes
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>
      
      <div className="mb-4">
        <div className="flex flex-wrap gap-2 mb-3">
          <button
            onClick={() => handleQuickQuestion('Preciso de peças para Onix 2020')}
            className="text-xs bg-gray-100 hover:bg-gray-200 text-gray-800 px-3 py-1.5 rounded-full flex items-center"
          >
            <Car className="w-3 h-3 mr-1" />
            Peças para Onix 2020
          </button>
          <button
            onClick={() => handleQuickQuestion('Quero melhorar o desempenho do meu carro')}
            className="text-xs bg-gray-100 hover:bg-gray-200 text-gray-800 px-3 py-1.5 rounded-full flex items-center"
          >
            <Settings className="w-3 h-3 mr-1" />
            Melhorar desempenho
          </button>
          <button
            onClick={() => handleQuickQuestion('Preciso de freios para HB20')}
            className="text-xs bg-gray-100 hover:bg-gray-200 text-gray-800 px-3 py-1.5 rounded-full flex items-center"
          >
            <Wrench className="w-3 h-3 mr-1" />
            Freios HB20
          </button>
          <button
            onClick={() => handleQuickQuestion('Acompanhar meu pedido')}
            className="text-xs bg-gray-100 hover:bg-gray-200 text-gray-800 px-3 py-1.5 rounded-full flex items-center"
          >
            <Package className="w-3 h-3 mr-1" />
            Acompanhar pedido
          </button>
        </div>
        
        <form onSubmit={handleSendMessage} className="flex gap-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Digite sua mensagem..."
            className="flex-1 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          <button
            type="submit"
            disabled={isLoading || !input.trim()}
            className="bg-blue-500 hover:bg-blue-600 text-white p-3 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
          >
            <Send className="w-5 h-5" />
          </button>
        </form>
      </div>
      
      <div className="text-center text-xs text-gray-500 mt-2">
        <p>AutoParts AI - Assistente virtual para peças automotivas e tuning</p>
      </div>
    </div>
  );
}
