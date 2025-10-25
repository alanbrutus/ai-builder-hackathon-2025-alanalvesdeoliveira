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
  
  // Listas para os selects
  const [grupos, setGrupos] = useState<GrupoEmpresarial[]>([]);
  const [fabricantes, setFabricantes] = useState<Fabricante[]>([]);
  const [modelos, setModelos] = useState<Modelo[]>([]);
  
  const bottomRef = useRef<HTMLDivElement | null>(null);

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

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

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

  const addAssistant = (content: string) => {
    setMessages((prev) => [
      ...prev,
      { id: crypto.randomUUID(), role: "assistant", content },
    ]);
  };

  const addUser = (content: string) => {
    setMessages((prev) => [
      ...prev,
      { id: crypto.randomUUID(), role: "user", content },
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

    try {
      const grupoSelecionado = grupos.find(g => g.Id === parseInt(grupoId));
      const fabricanteSelecionado = fabricantes.find(f => f.Id === parseInt(fabricanteId));
      const modeloSelecionado = modelos.find(m => m.Id === parseInt(modeloId));

      // Primeiro: Identificar peças na mensagem
      const identificacaoResponse = await fetch('/api/identificar-pecas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          conversaId: conversaId,
          mensagem: text,
          grupoEmpresarial: grupoSelecionado?.Nome || '',
          fabricanteVeiculo: fabricanteSelecionado?.Nome || '',
          modeloVeiculo: modeloSelecionado?.Nome || ''
        })
      });

      const identificacaoData = await identificacaoResponse.json();

      // Se não identificou peças, usar resposta direta da IA
      if (!identificacaoData.identificado) {
        addAssistant(identificacaoData.mensagem || "Como posso ajudar você?");
        setLoading(false);
        return;
      }

      // Se identificou peças, buscar recomendações
      const promptResponse = await fetch('/api/prompts/recomendacao');
      const promptData = await promptResponse.json();
      
      let systemPrompt = '';
      
      if (promptData.success) {
        systemPrompt = promptData.data.ConteudoPrompt;
        systemPrompt = systemPrompt.replace(/\{\{nome_cliente\}\}/g, name);
        systemPrompt = systemPrompt.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteSelecionado?.Nome || '');
        systemPrompt = systemPrompt.replace(/\{\{modelo_veiculo\}\}/g, modeloSelecionado?.Nome || '');
        systemPrompt = systemPrompt.replace(/\{\{problema_cliente\}\}/g, text);
        systemPrompt = systemPrompt.replace(/\{\{categoria_interesse\}\}/g, text);
      } else {
        systemPrompt = `Você é um assistente especializado em peças automotivas.
O cliente ${name} possui um ${fabricanteSelecionado?.Nome} ${modeloSelecionado?.Nome}.
Ajude com: ${text}`;
      }

      // Enviar para Gemini para recomendações detalhadas
      const aiResponse = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt: systemPrompt,
          message: text
        })
      });

      const aiData = await aiResponse.json();

      if (aiData.success) {
        // Adicionar informação sobre peças identificadas
        let resposta = aiData.response;
        
        if (identificacaoData.pecas && identificacaoData.pecas.length > 0) {
          resposta += `\n\n📋 **Peças identificadas para seu veículo:**\n`;
          identificacaoData.pecas.forEach((peca: any) => {
            resposta += `• ${peca.NomePeca}\n`;
          });
        }
        
        addAssistant(resposta);
      } else {
        addAssistant("Desculpe, ocorreu um erro ao processar sua mensagem. Tente novamente.");
      }
    } catch (error) {
      console.error('Erro:', error);
      addAssistant("Desculpe, ocorreu um erro. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex h-screen">
      {/* Sidebar - Formulário */}
      <div className="w-80 bg-gray-50 border-r border-gray-200 p-6 overflow-y-auto">
        <div className="mb-6">
          <Image
            src="/images/AutoPartAI.jpg"
            alt="AutoParts AI"
            width={240}
            height={80}
            className="mb-4 rounded-lg"
            priority
          />
          <Link href="/" className="text-blue-600 hover:underline text-sm">
            ← Voltar ao início
          </Link>
        </div>

        <h2 className="text-xl font-bold text-gray-900 mb-4">Dados do Veículo</h2>
        
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Seu Nome *
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              disabled={chatStarted}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
              placeholder="Digite seu nome"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Grupo Empresarial *
            </label>
            <select
              value={grupoId}
              onChange={(e) => setGrupoId(e.target.value)}
              disabled={chatStarted}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
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
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Fabricante *
            </label>
            <select
              value={fabricanteId}
              onChange={(e) => setFabricanteId(e.target.value)}
              disabled={chatStarted || !grupoId}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
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
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Modelo *
            </label>
            <select
              value={modeloId}
              onChange={(e) => setModeloId(e.target.value)}
              disabled={chatStarted || !fabricanteId}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
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
              className="w-full px-4 py-3 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Iniciar Chat
            </button>
          )}

          {chatStarted && (
            <div className="p-3 bg-green-50 border border-green-200 rounded-md">
              <p className="text-sm text-green-800 font-medium">✓ Chat iniciado</p>
              <p className="text-xs text-green-600 mt-1">
                {name} - {modelos.find(m => m.Id === parseInt(modeloId))?.Nome}
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Chat Area */}
      <div className="flex-1 flex flex-col">
        <div className="bg-white border-b border-gray-200 p-4 flex items-center gap-4">
          <Image
            src="/images/AutoPartAI.jpg"
            alt="AutoParts AI"
            width={60}
            height={60}
            className="rounded-lg"
          />
          <div>
            <h1 className="text-2xl font-semibold text-gray-900">Chat com IA</h1>
            <p className="text-sm text-gray-500 mt-1">AutoParts AI - Assistente Virtual</p>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto p-6 bg-gray-50">
          {!chatStarted ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-center">
                <div className="text-6xl mb-4">🤖</div>
                <h3 className="text-xl font-medium text-gray-900 mb-2">
                  Preencha os dados ao lado para iniciar
                </h3>
                <p className="text-gray-500">
                  Informe seu nome e os dados do seu veículo
                </p>
              </div>
            </div>
          ) : (
            <div className="max-w-4xl mx-auto space-y-4">
              {messages.map((m) => (
                <div key={m.id} className="flex">
                  <div
                    className={
                      m.role === "assistant"
                        ? "bg-white text-gray-900 border border-gray-200 ml-0 mr-auto rounded-2xl rounded-tl-sm px-4 py-3 max-w-[80%] shadow-sm"
                        : "bg-blue-600 text-white ml-auto mr-0 rounded-2xl rounded-tr-sm px-4 py-3 max-w-[80%]"
                    }
                  >
                    <div className="whitespace-pre-line">{m.content}</div>
                  </div>
                </div>
              ))}
              
              {loading && (
                <div className="flex justify-start">
                  <div className="bg-white border border-gray-200 p-3 rounded-lg rounded-tl-sm shadow-sm">
                    <div className="flex space-x-2">
                      <div className="w-2 h-2 rounded-full bg-blue-400 animate-bounce" style={{ animationDelay: "0ms" }}></div>
                      <div className="w-2 h-2 rounded-full bg-blue-400 animate-bounce" style={{ animationDelay: "150ms" }}></div>
                      <div className="w-2 h-2 rounded-full bg-blue-400 animate-bounce" style={{ animationDelay: "300ms" }}></div>
                    </div>
                  </div>
                </div>
              )}
              
              <div ref={bottomRef} />
            </div>
          )}
        </div>

        {chatStarted && (
          <form onSubmit={handleSubmit} className="border-t border-gray-200 bg-white p-4">
            <div className="max-w-4xl mx-auto flex items-center gap-2">
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="Digite sua mensagem..."
                disabled={loading}
                className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
              />
              <button
                type="submit"
                disabled={loading || !input.trim()}
                className="px-6 py-3 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Enviar
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}
