import { FC } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import Sidebar from '@/components/shared/Sidebar';
import Header from '@/components/shared/Header';

const getTitleFromPath = (pathname: string): string => {
  const path = pathname.split('/').pop();
  switch (path) {
    case '':
      return 'Overview';
    case 'wallets':
      return 'Wallets';
    case 'transactions':
      return 'Transactions';
    default:
      return 'AnotAI';
  }
};

const DashboardLayout: FC = () => {
  const location = useLocation();
  const title = getTitleFromPath(location.pathname);

  return (
    <div className="flex min-h-screen w-full flex-col bg-muted/40">
      <Sidebar />
      <div className="flex flex-col sm:gap-4 sm:py-4 sm:pl-14">
        <Header title={title} />
        <main className="flex-1 gap-4 p-4 sm:px-6 sm:py-0 md:gap-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default DashboardLayout;
