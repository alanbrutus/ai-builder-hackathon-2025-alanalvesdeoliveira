"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";

type Role = "assistant" | "user";

type Message = {
  id: string;
  role: Role;
  content: string;
};

type Step = "ask_name" | "ask_brand" | "ask_model" | "summary";

export default function ChatPage() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [step, setStep] = useState<Step>("ask_name");
  const [name, setName] = useState<string>("");
  const [brand, setBrand] = useState<string>("");
  const [model, setModel] = useState<string>("");
  const bottomRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (messages.length === 0) {
      addAssistant(
        "Olá! Eu sou a AutoParts AI. Para te ajudar, qual é o seu nome?"
      );
    }
  }, []);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

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

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const text = input.trim();
    if (!text) return;

    addUser(text);
    setInput("");

    if (step === "ask_name") {
      setName(text);
      addAssistant(
        `Prazer, ${text}! Agora me diga a marca do seu veículo (ex.: Chevrolet, Ford, Volkswagen, Fiat, Toyota).`
      );
      setStep("ask_brand");
      return;
    }

    if (step === "ask_brand") {
      setBrand(text);
      addAssistant(
        `Perfeito. Qual é o modelo do seu ${text}? (ex.: Onix, Corolla, Civic, HB20, Ranger)`
      );
      setStep("ask_model");
      return;
    }

    if (step === "ask_model") {
      setModel(text);
      setStep("summary");
      addAssistant(
        `Certo, ${name}. Você está buscando peças para um ${brand} ${text}. Vou preparar recomendações compatíveis. Deseja focar em alguma categoria? (ex.: Freios, Motor, Suspensão, Elétrica)`
      );
      return;
    }

    if (step === "summary") {
      addAssistant(
        `Anotado: ${name} | Veículo: ${brand} ${model}. Preferência: ${text}. Em breve mostrarei as melhores opções com base no seu veículo.`
      );
      return;
    }
  };

  const placeholder = useMemo(() => {
    if (step === "ask_name") return "Digite seu nome";
    if (step === "ask_brand") return "Informe a marca";
    if (step === "ask_model") return "Informe o modelo";
    return "Escreva sua mensagem";
  }, [step]);

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="text-2xl font-semibold text-gray-900">Chat com IA</h2>
        <Link href="/" className="text-blue-600 hover:underline">Voltar ao início</Link>
      </div>

      <div className="bg-white rounded-lg shadow border border-gray-100 flex flex-col h-[70vh]">
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.map((m) => (
            <div key={m.id} className="flex">
              <div
                className={
                  m.role === "assistant"
                    ? "bg-blue-50 text-gray-900 border border-blue-100 ml-0 mr-auto rounded-2xl rounded-tl-sm px-4 py-3 max-w-[80%]"
                    : "bg-gray-900 text-white ml-auto mr-0 rounded-2xl rounded-tr-sm px-4 py-3 max-w-[80%]"
                }
              >
                {m.content}
              </div>
            </div>
          ))}
          <div ref={bottomRef} />
        </div>
        <form onSubmit={handleSubmit} className="border-t border-gray-100 p-3">
          <div className="flex items-center gap-2">
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={placeholder}
              className="flex-1 px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <button
              type="submit"
              className="px-4 py-3 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700"
            >
              Enviar
            </button>
          </div>
        </form>
      </div>

      <div className="mt-4 text-sm text-gray-500">
        <p>Foco: Sedans, Hatchbacks, Pick-ups pequenas e médias e SUVs. Não atendemos veículos de carga, motocicletas e ciclomotores.</p>
      </div>
    </div>
  );
}
