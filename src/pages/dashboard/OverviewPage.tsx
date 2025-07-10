import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import Header from '@/components/shared/Header';
import { supabase } from '@/lib/supabase';
import { Database } from '@/types/database.types';
import { PlusCircle } from 'lucide-react';

type Workspace = Database['public']['Tables']['workspaces']['Row'];

export default function OverviewPage() {
  const [workspaces, setWorkspaces] = useState<Workspace[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchWorkspaces = async () => {
      setLoading(true);
      const { data, error } = await supabase.from('workspaces').select('*');

      if (error) {
        setError(error.message);
        console.error('Error fetching workspaces:', error);
      } else {
        setWorkspaces(data);
      }
      setLoading(false);
    };

    fetchWorkspaces();
  }, []);

  return (
    <>
      <Header title="Overview" />
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
         <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                Total Revenue
              </CardTitle>
              <span className="text-2xl">💸</span>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">$0.00</div>
              <p className="text-xs text-muted-foreground">
                Based on all transactions
              </p>
            </CardContent>
          </Card>
           <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                Transactions
              </CardTitle>
              <span className="text-2xl">🔄</span>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">+0</div>
              <p className="text-xs text-muted-foreground">
                This month
              </p>
            </CardContent>
          </Card>
      </div>
      <div className="mt-8">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Workspaces</CardTitle>
              <CardDescription>
                Your teams and personal finance spaces.
              </CardDescription>
            </div>
            <Button size="sm" className="gap-1" disabled>
                <PlusCircle className="h-3.5 w-3.5" />
                <span className="sr-only sm:not-sr-only sm:whitespace-nowrap">
                  New Workspace
                </span>
              </Button>
          </CardHeader>
          <CardContent>
            {loading && <p>Loading workspaces...</p>}
            {error && <p className="text-destructive">Error: {error}</p>}
            {!loading && !error && workspaces.length === 0 && (
              <div className="text-center py-8">
                <p className="text-muted-foreground">No workspaces found.</p>
                <p className="text-sm text-muted-foreground">Get started by creating a new workspace.</p>
              </div>
            )}
            {!loading && workspaces.length > 0 && (
              <ul className="divide-y divide-border">
                {workspaces.map((ws) => (
                  <li key={ws.id} className="py-3 font-medium">
                    {ws.name}
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>
      </div>
    </>
  );
}
