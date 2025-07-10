import { FC } from 'react';
import { Outlet } from 'react-router-dom';
import { PiggyBank } from 'lucide-react';

const AuthLayout: FC = () => {
  return (
    <div className="w-full lg:grid lg:min-h-screen lg:grid-cols-2">
      <div className="flex items-center justify-center py-12">
        <Outlet />
      </div>
      <div className="hidden bg-muted lg:block">
        <div className="flex flex-col items-center justify-center h-full text-center p-12 bg-zinc-900 text-white">
            <PiggyBank className="h-16 w-16 mb-4 text-green-400" />
            <h1 className="text-4xl font-bold mb-2">AnotAI</h1>
            <p className="text-xl text-zinc-300">Your intelligent financial companion. Gain clarity and control over your finances.</p>
        </div>
      </div>
    </div>
  );
};

export default AuthLayout;
