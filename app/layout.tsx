import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'AutoParts AI - Assistente Virtual para Peças Automotivas',
  description: 'Chat de IA especializado em peças de reposição e tuning para veículos',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR">
      <body className={`${inter.className} bg-gray-50`}>
        <div className="min-h-screen flex flex-col">
          <header className="bg-white shadow-sm">
            <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
              <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-blue-600">AutoParts AI</h1>
                <nav className="hidden md:flex space-x-8">
                  <a href="#" className="text-gray-700 hover:text-blue-600">Início</a>
                  <a href="#" className="text-gray-700 hover:text-blue-600">Peças</a>
                  <a href="#" className="text-gray-700 hover:text-blue-600">Tuning</a>
                  <a href="/chat" className="text-gray-700 hover:text-blue-600">Chat</a>
                  <a href="#" className="text-gray-700 hover:text-blue-600">Sobre</a>
                  <a href="#" className="text-gray-700 hover:text-blue-600">Contato</a>
                </nav>
                <button className="md:hidden">
                  <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16m-7 6h7" />
                  </svg>
                </button>
              </div>
            </div>
          </header>
          
          <main className="flex-grow">
            {children}
          </main>
          
          <footer className="bg-gray-800 text-white py-8">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                <div>
                  <h3 className="text-lg font-semibold mb-4">AutoParts AI</h3>
                  <p className="text-gray-400">Soluções em peças automotivas e tuning com inteligência artificial.</p>
                </div>
                <div>
                  <h4 className="text-md font-semibold mb-4">Navegação</h4>
                  <ul className="space-y-2">
                    <li><a href="#" className="text-gray-400 hover:text-white">Início</a></li>
                    <li><a href="#" className="text-gray-400 hover:text-white">Produtos</a></li>
                    <li><a href="#" className="text-gray-400 hover:text-white">Sobre Nós</a></li>
                    <li><a href="#" className="text-gray-400 hover:text-white">Contato</a></li>
                  </ul>
                </div>
                <div>
                  <h4 className="text-md font-semibold mb-4">Categorias</h4>
                  <ul className="space-y-2">
                    <li><a href="#" className="text-gray-400 hover:text-white">Suspensão</a></li>
                    <li><a href="#" className="text-gray-400 hover:text-white">Motor</a></li>
                    <li><a href="#" className="text-gray-400 hover:text-white">Freios</a></li>
                    <li><a href="#" className="text-gray-400 hover:text-white">Interior</a></li>
                  </ul>
                </div>
                <div>
                  <h4 className="text-md font-semibold mb-4">Contato</h4>
                  <ul className="space-y-2">
                    <li className="flex items-center">
                      <svg className="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                      </svg>
                      <span className="text-gray-400">contato@autopartsai.com</span>
                    </li>
                    <li className="flex items-center">
                      <svg className="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                      </svg>
                      <span className="text-gray-400">(11) 1234-5678</span>
                    </li>
                  </ul>
                </div>
              </div>
              <div className="border-t border-gray-700 mt-8 pt-8 text-center text-gray-400">
                <p>© {new Date().getFullYear()} AutoParts AI. Todos os direitos reservados.</p>
              </div>
            </div>
          </footer>
        </div>
      </body>
    </html>
  );
}
