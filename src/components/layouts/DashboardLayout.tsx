import { Outlet, Link } from 'react-router-dom';
import { Home, Wallet, BarChart, Settings } from 'lucide-react';

const DashboardLayout = () => {
  return (
    <div className="flex h-screen bg-gray-50 dark:bg-gray-900">
      <aside className="w-64 flex-shrink-0 bg-white dark:bg-gray-800 border-r dark:border-gray-700">
        <div className="h-full flex flex-col">
          <div className="p-4 border-b dark:border-gray-700">
            <h1 className="text-2xl font-bold text-gray-800 dark:text-white">AnotAI</h1>
            <p className="text-sm text-gray-500 dark:text-gray-400">Suas finanças, inteligentes.</p>
          </div>
          <nav className="flex-1 px-2 py-4 space-y-2">
            <Link to="/" className="flex items-center px-4 py-2 text-gray-700 dark:text-gray-200 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700">
              <Home className="w-5 h-5 mr-3" />
              Visão Geral
            </Link>
            <Link to="/wallets" className="flex items-center px-4 py-2 text-gray-700 dark:text-gray-200 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700">
              <Wallet className="w-5 h-5 mr-3" />
              Carteiras
            </Link>
            <Link to="/transactions" className="flex items-center px-4 py-2 text-gray-700 dark:text-gray-200 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700">
              <BarChart className="w-5 h-5 mr-3" />
              Transações
            </Link>
          </nav>
          <div className="p-2 border-t dark:border-gray-700">
             <Link to="/settings" className="flex items-center px-4 py-2 text-gray-700 dark:text-gray-200 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700">
              <Settings className="w-5 h-5 mr-3" />
              Configurações
            </Link>
          </div>
        </div>
      </aside>
      <main className="flex-1 overflow-y-auto p-6 lg:p-8">
        <Outlet />
      </main>
    </div>
  );
};

export default DashboardLayout;
