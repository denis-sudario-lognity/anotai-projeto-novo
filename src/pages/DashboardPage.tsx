import { Button } from "@/components/ui/button";
import { useAuth } from "@/hooks/useAuth";

export default function DashboardPage() {
  const { user, signOut } = useAuth();

  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-50">
      <div className="text-center">
        <h1 className="text-4xl font-bold">Welcome to AnotAI</h1>
        <p className="mt-2 text-lg text-muted-foreground">
          You are logged in as: <span className="font-semibold text-primary">{user?.email}</span>
        </p>
        <p className="mt-4">This is your main dashboard. More features coming soon!</p>
        <Button onClick={signOut} className="mt-6">
          Sign Out
        </Button>
      </div>
    </div>
  );
}
