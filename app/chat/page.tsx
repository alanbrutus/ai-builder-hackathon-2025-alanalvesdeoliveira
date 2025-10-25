"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";

type Role = "assistant" | "user";

type Message = {
  id: string;
  role: Role;
  content: string;
  options?: SelectOption[];
};

type SelectOption = {
  id: number;
  label: string;
  sublabel?: string;
};

type Step = "ask_name" | "select_grupo" | "select_fabricante" | "select_modelo" | "select_categoria" | "summary";

interface GrupoEmpresarial {
  Id: number;
  Nome: string;
  Descricao: string;
  TotalFabricantes: number;
  TotalModelos: number;
}

interface Fabricante {
  Id: number;
  Nome: string;
  Pais: string;
  TotalModelos: number;
}

interface Modelo {
  Id: number;
  Nome: string;
  Periodo: string;
  TipoVeiculo: string;
}

export default function ChatPage() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [step, setStep] = useState<Step>("ask_name");
  const [loading, setLoading] = useState(false);
  
  // Dados do cliente
  const [name, setName] = useState<string>("");
  const [grupoId, setGrupoId] = useState<number | null>(null);
  const [grupoNome, setGrupoNome] = useState<string>("");
  const [fabricanteId, setFabricanteId] = useState<number | null>(null);
  const [fabricanteNome, setFabricanteNome] = useState<string>("");
  const [modeloId, setModeloId] = useState<number | null>(null);
  const [modeloNome, setModeloNome] = useState<string>("");
  
  const bottomRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (messages.length === 0) {
      addAssistant("Olá! Eu sou a AutoParts AI. Para te ajudar, qual é o seu nome?");
    }
  }, []);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const addAssistant = (content: string, options?: SelectOption[]) => {
    setMessages((prev) => [
      ...prev,
      { id: crypto.randomUUID(), role: "assistant", content, options },
    ]);
  };

  const addUser = (content: string) => {
    setMessages((prev) => [
      ...prev,
      { id: crypto.randomUUID(), role: "user", content },
    ]);
  };

  const loadGrupos = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/grupos');
      const data = await response.json();
      
      if (data.success && data.data.length > 0) {
        const options: SelectOption[] = data.data.map((g: GrupoEmpresarial) => ({
          id: g.Id,
          label: g.Nome,
          sublabel: `${g.TotalFabricantes} fabricantes, ${g.TotalModelos} modelos`,
        }));
        
        addAssistant(
          `Perfeito, ${name}! Agora selecione o grupo empresarial do seu veículo:`,
          options
        );
        setStep("select_grupo");
      }
    } catch (error) {
      console.error('Erro ao carregar grupos:', error);
      addAssistant("Desculpe, ocorreu um erro ao carregar os grupos. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  const loadFabricantes = async (grupoIdParam: number, grupoNomeParam: string) => {
    setLoading(true);
    try {
      const response = await fetch(`/api/fabricantes/${grupoIdParam}`);
      const data = await response.json();
      
      if (data.success && data.data.length > 0) {
        const options: SelectOption[] = data.data.map((f: Fabricante) => ({
          id: f.Id,
          label: f.Nome,
          sublabel: `${f.Pais} - ${f.TotalModelos} modelos`,
        }));
        
        addUser(grupoNomeParam);
        addAssistant(
          `Ótimo! O grupo ${grupoNomeParam} possui ${data.data.length} fabricantes. Qual é o fabricante do seu veículo?`,
          options
        );
        setStep("select_fabricante");
      }
    } catch (error) {
      console.error('Erro ao carregar fabricantes:', error);
      addAssistant("Desculpe, ocorreu um erro ao carregar os fabricantes. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  const loadModelos = async (fabricanteIdParam: number, fabricanteNomeParam: string) => {
    setLoading(true);
    try {
      const response = await fetch(`/api/modelos/${fabricanteIdParam}`);
      const data = await response.json();
      
      if (data.success && data.data.length > 0) {
        const options: SelectOption[] = data.data.map((m: Modelo) => ({
          id: m.Id,
          label: m.Nome,
          sublabel: `${m.TipoVeiculo} - ${m.Periodo}`,
        }));
        
        addUser(fabricanteNomeParam);
        addAssistant(
          `Perfeito! Qual modelo de ${fabricanteNomeParam} você possui?`,
          options
        );
        setStep("select_modelo");
      }
    } catch (error) {
      console.error('Erro ao carregar modelos:', error);
      addAssistant("Desculpe, ocorreu um erro ao carregar os modelos. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  const loadPromptAtendimento = async (modeloNomeParam: string) => {
    setLoading(true);
    try {
      // Buscar prompt do banco de dados
      const response = await fetch('/api/prompts/atendimento');
      const data = await response.json();
      
      if (data.success) {
        // Substituir variáveis no prompt
        let promptProcessado = data.data.ConteudoPrompt;
        promptProcessado = promptProcessado.replace(/\{\{nome_cliente\}\}/g, name);
        promptProcessado = promptProcessado.replace(/\{\{grupo_empresarial\}\}/g, grupoNome);
        promptProcessado = promptProcessado.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteNome);
        promptProcessado = promptProcessado.replace(/\{\{modelo_veiculo\}\}/g, modeloNomeParam);
        
        addAssistant(promptProcessado);
        setStep("select_categoria");
      } else {
        // Fallback caso o prompt não seja encontrado
        addAssistant(
          `Excelente, ${name}! Você possui um ${fabricanteNome} ${modeloNomeParam} do grupo ${grupoNome}.\n\nAgora, em qual categoria de peças você está interessado?\n\n• Motor\n• Suspensão\n• Freios\n• Transmissão\n• Elétrica\n• Carroceria\n• Filtros\n• Iluminação\n• Arrefecimento\n• Escapamento`
        );
        setStep("select_categoria");
      }
    } catch (error) {
      console.error('Erro ao carregar prompt:', error);
      // Fallback em caso de erro
      addAssistant(
        `Excelente, ${name}! Você possui um ${fabricanteNome} ${modeloNomeParam} do grupo ${grupoNome}.\n\nAgora, em qual categoria de peças você está interessado?\n\n• Motor\n• Suspensão\n• Freios\n• Transmissão\n• Elétrica\n• Carroceria\n• Filtros\n• Iluminação\n• Arrefecimento\n• Escapamento`
      );
      setStep("select_categoria");
    } finally {
      setLoading(false);
    }
  };

  const sendToAI = async (categoria: string) => {
    setLoading(true);
    try {
      // Buscar prompt de recomendação do banco
      const promptResponse = await fetch('/api/prompts/recomendacao');
      const promptData = await promptResponse.json();
      
      let systemPrompt = '';
      
      if (promptData.success) {
        // Usar prompt do banco e substituir variáveis
        systemPrompt = promptData.data.ConteudoPrompt;
        systemPrompt = systemPrompt.replace(/\{\{nome_cliente\}\}/g, name);
        systemPrompt = systemPrompt.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteNome);
        systemPrompt = systemPrompt.replace(/\{\{modelo_veiculo\}\}/g, modeloNome);
        systemPrompt = systemPrompt.replace(/\{\{problema_cliente\}\}/g, `Interesse em peças da categoria: ${categoria}`);
        systemPrompt = systemPrompt.replace(/\{\{categoria_interesse\}\}/g, categoria);
      } else {
        // Fallback: prompt padrão
        systemPrompt = `Você é um assistente especializado em peças automotivas.
O cliente ${name} possui um ${fabricanteNome} ${modeloNome}.
Ele está interessado em peças da categoria: ${categoria}.

Forneça recomendações de peças compatíveis, explicando:
1. Quais peças são necessárias
2. Diferenças entre opções originais e alternativas
3. Faixa de preço estimada
4. Importância da manutenção preventiva

Seja técnico mas didático.`;
      }

      // Enviar para o Gemini
      const aiResponse = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt: systemPrompt,
          message: `Preciso de orientação sobre peças da categoria ${categoria} para meu veículo.`
        })
      });

      const aiData = await aiResponse.json();

      if (aiData.success) {
        addAssistant(aiData.response);
        setStep("summary");
      } else {
        addAssistant(
          `Desculpe, tive um problema ao processar sua solicitação. Mas posso te ajudar com peças da categoria ${categoria} para seu ${fabricanteNome} ${modeloNome}. Pode me dar mais detalhes sobre o que você precisa?`
        );
      }
    } catch (error) {
      console.error('Erro ao enviar para IA:', error);
      addAssistant(
        `Desculpe, ocorreu um erro ao processar sua mensagem. Por favor, tente novamente ou entre em contato com nosso suporte.`
      );
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const text = input.trim();
    if (!text || loading) return;

    if (step === "ask_name") {
      setName(text);
      addUser(text);
      loadGrupos();
      setInput("");
      return;
    }

    if (step === "select_categoria") {
      addUser(text);
      sendToAI(text);
      setInput("");
      return;
    }

    setInput("");
  };

  const handleOptionClick = (option: SelectOption) => {
    if (loading) return;

    if (step === "select_grupo") {
      setGrupoId(option.id);
      setGrupoNome(option.label);
      loadFabricantes(option.id, option.label);
    } else if (step === "select_fabricante") {
      setFabricanteId(option.id);
      setFabricanteNome(option.label);
      loadModelos(option.id, option.label);
    } else if (step === "select_modelo") {
      setModeloId(option.id);
      setModeloNome(option.label);
      addUser(option.label);
      loadPromptAtendimento(option.label);
    }
  };

  const placeholder = useMemo(() => {
    if (step === "ask_name") return "Digite seu nome";
    if (step === "select_categoria") return "Digite a categoria (ex: Freios, Motor, Suspensão)";
    return "Aguardando seleção...";
  }, [step]);

  const showInput = step === "ask_name" || step === "select_categoria";

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="text-2xl font-semibold text-gray-900">Chat com IA</h2>
        <Link href="/" className="text-blue-600 hover:underline">
          Voltar ao início
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow border border-gray-100 flex flex-col h-[75vh]">
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.map((m) => (
            <div key={m.id}>
              <div className="flex">
                <div
                  className={
                    m.role === "assistant"
                      ? "bg-blue-50 text-gray-900 border border-blue-100 ml-0 mr-auto rounded-2xl rounded-tl-sm px-4 py-3 max-w-[85%]"
                      : "bg-gray-900 text-white ml-auto mr-0 rounded-2xl rounded-tr-sm px-4 py-3 max-w-[85%]"
                  }
                >
                  <div className="whitespace-pre-line">{m.content}</div>
                </div>
              </div>
              
              {/* Opções de seleção */}
              {m.options && m.options.length > 0 && (
                <div className="mt-3 ml-0 mr-auto max-w-[85%] grid grid-cols-1 gap-2">
                  {m.options.map((option) => (
                    <button
                      key={option.id}
                      onClick={() => handleOptionClick(option)}
                      disabled={loading}
                      className="text-left px-4 py-3 bg-white border-2 border-blue-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      <div className="font-medium text-gray-900">{option.label}</div>
                      {option.sublabel && (
                        <div className="text-sm text-gray-500 mt-1">{option.sublabel}</div>
                      )}
                    </button>
                  ))}
                </div>
              )}
            </div>
          ))}
          
          {loading && (
            <div className="flex justify-start">
              <div className="bg-blue-50 border border-blue-100 p-3 rounded-lg rounded-tl-sm">
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

        {showInput && (
          <form onSubmit={handleSubmit} className="border-t border-gray-100 p-3">
            <div className="flex items-center gap-2">
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder={placeholder}
                disabled={loading}
                className="flex-1 px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
              />
              <button
                type="submit"
                disabled={loading || !input.trim()}
                className="px-4 py-3 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Enviar
              </button>
            </div>
          </form>
        )}
      </div>

      <div className="mt-4 text-sm text-gray-500">
        <p>
          <strong>Hierarquia:</strong> Grupo Empresarial → Fabricante → Modelo
        </p>
        <p className="mt-1">
          Foco: Sedans, Hatchbacks, Pick-ups pequenas e médias e SUVs. Não atendemos veículos de carga, motocicletas e ciclomotores.
        </p>
      </div>
    </div>
  );
}
