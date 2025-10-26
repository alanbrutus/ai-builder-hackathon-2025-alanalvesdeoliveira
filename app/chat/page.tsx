"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import Image from "next/image";

type Role = "assistant" | "user";

type Message = {
  id: string;
  role: Role;
  content: string;
};

interface GrupoEmpresarial {
  Id: number;
  Nome: string;
}

interface Fabricante {
  Id: number;
  Nome: string;
}

interface Modelo {
  Id: number;
  Nome: string;
  TipoVeiculo: string;
  Periodo: string;
}

export default function ChatPage() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [chatStarted, setChatStarted] = useState(false);
  
  // Dados do formulário lateral
  const [name, setName] = useState("");
  const [grupoId, setGrupoId] = useState("");
  const [fabricanteId, setFabricanteId] = useState("");
  const [modeloId, setModeloId] = useState("");
  
  // ID da conversa no banco
  const [conversaId, setConversaId] = useState<number | null>(null);
  
  // Contador de mensagens do cliente (para controlar fluxo)
  const [mensagensCliente, setMensagensCliente] = useState(0);
  
  // Listas para os selects
  const [grupos, setGrupos] = useState<GrupoEmpresarial[]>([]);
  const [fabricantes, setFabricantes] = useState<Fabricante[]>([]);
  const [modelos, setModelos] = useState<Modelo[]>([]);
  
  const bottomRef = useRef<HTMLDivElement | null>(null);
  const inputFormRef = useRef<HTMLFormElement | null>(null);

  // Carregar grupos ao montar
  useEffect(() => {
    loadGrupos();
  }, []);

  // Carregar fabricantes quando grupo mudar
  useEffect(() => {
    if (grupoId) {
      loadFabricantes(parseInt(grupoId));
    } else {
      setFabricantes([]);
      setFabricanteId("");
    }
  }, [grupoId]);

  // Carregar modelos quando fabricante mudar
  useEffect(() => {
    if (fabricanteId) {
      loadModelos(parseInt(fabricanteId));
    } else {
      setModelos([]);
      setModeloId("");
    }
  }, [fabricanteId]);

  // Rolar para o final das mensagens quando novas mensagens chegarem
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Rolar para o topo (input) quando loading terminar
  useEffect(() => {
    if (!loading && chatStarted && inputFormRef.current) {
      inputFormRef.current.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }, [loading, chatStarted]);

  const loadGrupos = async () => {
    try {
      const response = await fetch('/api/grupos');
      const data = await response.json();
      if (data.success) {
        setGrupos(data.data);
      }
    } catch (error) {
      console.error('Erro ao carregar grupos:', error);
    }
  };

  const loadFabricantes = async (grupoIdParam: number) => {
    try {
      const response = await fetch(`/api/fabricantes/${grupoIdParam}`);
      const data = await response.json();
      if (data.success) {
        setFabricantes(data.data);
      }
    } catch (error) {
      console.error('Erro ao carregar fabricantes:', error);
    }
  };

  const loadModelos = async (fabricanteIdParam: number) => {
    try {
      const response = await fetch(`/api/modelos/${fabricanteIdParam}`);
      const data = await response.json();
      if (data.success) {
        setModelos(data.data);
      }
    } catch (error) {
      console.error('Erro ao carregar modelos:', error);
    }
  };

  const generateId = () => {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  };

  const addAssistant = (content: string) => {
    setMessages((prev) => [
      ...prev,
      { id: generateId(), role: "assistant", content },
    ]);
  };

  const addUser = (content: string) => {
    setMessages((prev) => [
      ...prev,
      { id: generateId(), role: "user", content },
    ]);
  };

  const handleStartChat = async () => {
    if (!name || !grupoId || !fabricanteId || !modeloId) {
      alert("Por favor, preencha todos os campos antes de iniciar o chat.");
      return;
    }

    try {
      // Criar conversa no banco
      const response = await fetch('/api/conversas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          nomeCliente: name,
          grupoEmpresarialId: parseInt(grupoId),
          fabricanteId: parseInt(fabricanteId),
          modeloId: parseInt(modeloId)
        })
      });

      const data = await response.json();

      if (data.success) {
        setConversaId(data.data.Id);
        setChatStarted(true);
        
        const fabricanteSelecionado = fabricantes.find(f => f.Id === parseInt(fabricanteId));
        const modeloSelecionado = modelos.find(m => m.Id === parseInt(modeloId));

        // Mensagem de boas-vindas simples (não mostra o prompt técnico)
        addAssistant(
          `Olá ${name}! 👋\n\nVejo que você tem um ${fabricanteSelecionado?.Nome} ${modeloSelecionado?.Nome}. Estou aqui para ajudar com peças e acessórios para o seu veículo.\n\nComo posso ajudar você hoje?`
        );
      } else {
        alert('Erro ao iniciar conversa. Tente novamente.');
      }
    } catch (error) {
      console.error('Erro ao iniciar chat:', error);
      alert('Erro ao iniciar conversa. Tente novamente.');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const text = input.trim();
    if (!text || loading || !conversaId) return;

    addUser(text);
    setInput("");
    setLoading(true);

    // Incrementar contador de mensagens
    const numeroMensagem = mensagensCliente + 1;
    setMensagensCliente(numeroMensagem);

    try {
      const grupoSelecionado = grupos.find(g => g.Id === parseInt(grupoId));
      const fabricanteSelecionado = fabricantes.find(f => f.Id === parseInt(fabricanteId));
      const modeloSelecionado = modelos.find(m => m.Id === parseInt(modeloId));

      console.log(`📨 Mensagem #${numeroMensagem} do cliente`);
      
      if (numeroMensagem === 1) {
        // PRIMEIRA MENSAGEM - Identificar peças
        console.log('🔍 Primeira mensagem. Identificando peças...');
        
        const identificacaoResponse = await fetch('/api/identificar-pecas', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            conversaId: conversaId,
            mensagem: text,
            nomeCliente: name,
            grupoEmpresarial: grupoSelecionado?.Nome || '',
            fabricanteVeiculo: fabricanteSelecionado?.Nome || '',
            modeloVeiculo: modeloSelecionado?.Nome || ''
          })
        });

        const identificacaoData = await identificacaoResponse.json();
        console.log('📥 Resposta da identificação:', identificacaoData);

        if (identificacaoData.success) {
          const resposta = identificacaoData.respostaCompleta || identificacaoData.mensagem;
          if (resposta) {
            addAssistant(resposta);
          } else {
            console.error('❌ Resposta vazia da API');
            addAssistant("Desculpe, recebi uma resposta vazia. Tente novamente.");
          }
        } else {
          console.error('❌ Erro na API:', identificacaoData.error);
          const mensagemErro = identificacaoData.error || "Erro desconhecido";
          addAssistant(`Desculpe, ocorreu um erro: ${mensagemErro}. Tente novamente.`);
        }
      } else {
        // SEGUNDA MENSAGEM OU MAIS - Verificar se é cotação ou finalização
        console.log(`🔧 Mensagem #${numeroMensagem}. Verificando se é cotação ou finalização...`);
        console.log('   Mensagem:', text);
        
        const verificacaoResponse = await fetch('/api/gerar-cotacao', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            conversaId: conversaId,
            mensagemCliente: text
          })
        });
        
        const verificacaoData = await verificacaoResponse.json();
        
        if (verificacaoData.success && verificacaoData.intencaoCotacao) {
          // CLIENTE SOLICITOU COTAÇÃO
          console.log('💰 Intenção de cotação detectada!');
          console.log('   Palavras encontradas:', verificacaoData.palavrasEncontradas);
          
          if (verificacaoData.cotacao) {
            addAssistant(verificacaoData.cotacao);
          } else if (verificacaoData.mensagem) {
            addAssistant(verificacaoData.mensagem);
          }
        } else {
          // CLIENTE NÃO SOLICITOU COTAÇÃO - Finalizar
          console.log('🏁 Sem intenção de cotação. Finalizando atendimento...');
          console.log('   Dados enviados:', {
            conversaId,
            mensagemCliente: text,
            nomeCliente: name,
            fabricanteVeiculo: fabricanteSelecionado?.Nome,
            modeloVeiculo: modeloSelecionado?.Nome
          });
          
          const finalizacaoResponse = await fetch('/api/finalizar-atendimento', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              conversaId: conversaId,
              mensagemCliente: text,
              nomeCliente: name,
              fabricanteVeiculo: fabricanteSelecionado?.Nome || '',
              modeloVeiculo: modeloSelecionado?.Nome || '',
              diagnosticoAnterior: ''
            })
          });
          
          const finalizacaoData = await finalizacaoResponse.json();
          
          if (finalizacaoData.success && finalizacaoData.mensagem) {
            addAssistant(finalizacaoData.mensagem);
          }
        }
      }
    } catch (error) {
      console.error('Erro:', error);
      addAssistant("Desculpe, ocorreu um erro. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Sidebar - Formulário */}
      <div className="w-72 bg-gray-50 border-r border-gray-200 p-3 flex flex-col">
        <div className="mb-3">
          <Image
            src="/images/AutoPartAI.jpg"
            alt="AutoParts AI"
            width={200}
            height={60}
            className="mb-2 rounded-lg"
            priority
          />
          <Link href="/" className="text-blue-600 hover:underline text-xs">
            ← Voltar
          </Link>
        </div>

        <h2 className="text-base font-bold text-gray-900 mb-2">Dados do Veículo</h2>
        
        <div className="space-y-2 flex-1 overflow-y-auto">
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-0.5">
              Seu Nome *
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              disabled={chatStarted}
              className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
              placeholder="Digite seu nome"
            />
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-700 mb-0.5">
              Grupo Empresarial *
            </label>
            <select
              value={grupoId}
              onChange={(e) => setGrupoId(e.target.value)}
              disabled={chatStarted}
              className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
            >
              <option value="">Selecione...</option>
              {grupos.map((grupo) => (
                <option key={grupo.Id} value={grupo.Id}>
                  {grupo.Nome}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-700 mb-0.5">
              Fabricante *
            </label>
            <select
              value={fabricanteId}
              onChange={(e) => setFabricanteId(e.target.value)}
              disabled={chatStarted || !grupoId}
              className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
            >
              <option value="">Selecione...</option>
              {fabricantes.map((fabricante) => (
                <option key={fabricante.Id} value={fabricante.Id}>
                  {fabricante.Nome}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-700 mb-0.5">
              Modelo *
            </label>
            <select
              value={modeloId}
              onChange={(e) => setModeloId(e.target.value)}
              disabled={chatStarted || !fabricanteId}
              className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
            >
              <option value="">Selecione...</option>
              {modelos.map((modelo) => (
                <option key={modelo.Id} value={modelo.Id}>
                  {modelo.Nome} - {modelo.TipoVeiculo}
                </option>
              ))}
            </select>
          </div>

          {!chatStarted && (
            <button
              onClick={handleStartChat}
              disabled={!name || !grupoId || !fabricanteId || !modeloId}
              className="w-full px-3 py-2 text-sm bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Iniciar Chat
            </button>
          )}

          {chatStarted && (
            <div className="p-2 bg-green-50 border border-green-200 rounded-md">
              <p className="text-xs text-green-800 font-medium">✓ Chat iniciado</p>
              <p className="text-xs text-green-600 mt-0.5 truncate">
                {name} - {modelos.find(m => m.Id === parseInt(modeloId))?.Nome}
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Chat Area */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="bg-white border-b border-gray-200 p-2 flex items-center gap-2">
          <Image
            src="/images/AutoPartAI.jpg"
            alt="AutoParts AI"
            width={40}
            height={40}
            className="rounded-lg"
          />
          <div>
            <h1 className="text-base font-semibold text-gray-900">Chat com IA</h1>
            <p className="text-xs text-gray-500">AutoParts AI</p>
          </div>
        </div>

        {/* Input de Mensagem - Agora no topo */}
        {chatStarted && (
          <form ref={inputFormRef} onSubmit={handleSubmit} className="border-b border-gray-200 bg-white px-2 py-2">
            <div className="max-w-4xl mx-auto flex items-center gap-1.5">
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="Digite sua mensagem..."
                disabled={loading}
                autoFocus
                className="flex-1 px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
              />
              <button
                type="submit"
                disabled={loading || !input.trim()}
                className="px-4 py-2 text-sm rounded-md bg-blue-600 text-white font-medium hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed whitespace-nowrap"
              >
                {loading ? 'Enviando...' : 'Enviar'}
              </button>
            </div>
          </form>
        )}

        {/* Área de Mensagens - Agora abaixo do input */}
        <div className="flex-1 overflow-y-auto p-3 bg-gray-50">
          {!chatStarted ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-center">
                <div className="text-4xl mb-2">🤖</div>
                <h3 className="text-base font-medium text-gray-900 mb-1">
                  Preencha os dados ao lado
                </h3>
                <p className="text-xs text-gray-500">
                  Informe seu nome e dados do veículo
                </p>
              </div>
            </div>
          ) : (
            <div className="max-w-4xl mx-auto space-y-2">
              {messages.map((m) => (
                <div key={m.id} className="flex">
                  <div
                    className={
                      m.role === "assistant"
                        ? "bg-white text-gray-900 border border-gray-200 ml-0 mr-auto rounded-2xl rounded-tl-sm px-3 py-2 max-w-[80%] shadow-sm text-sm"
                        : "bg-blue-600 text-white ml-auto mr-0 rounded-2xl rounded-tr-sm px-3 py-2 max-w-[80%] text-sm"
                    }
                  >
                    <div className="whitespace-pre-line">{m.content}</div>
                  </div>
                </div>
              ))}
              
              {loading && (
                <div className="flex justify-start">
                  <div className="bg-white border border-gray-200 p-2 rounded-lg rounded-tl-sm shadow-sm">
                    <div className="flex space-x-1.5">
                      <div className="w-1.5 h-1.5 rounded-full bg-blue-400 animate-bounce" style={{ animationDelay: "0ms" }}></div>
                      <div className="w-1.5 h-1.5 rounded-full bg-blue-400 animate-bounce" style={{ animationDelay: "150ms" }}></div>
                      <div className="w-1.5 h-1.5 rounded-full bg-blue-400 animate-bounce" style={{ animationDelay: "300ms" }}></div>
                    </div>
                  </div>
                </div>
              )}
              
              <div ref={bottomRef} />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
