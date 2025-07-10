import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';

export default function NotFoundPage() {
  return (
    <div className="flex flex-col items-center justify-center h-screen text-center bg-background">
      <h1 className="text-9xl font-extrabold text-primary tracking-widest">404</h1>
      <div className="bg-primary px-2 text-sm rounded rotate-12 absolute text-primary-foreground">
        Page Not Found
      </div>
      <p className="mt-4 text-lg text-muted-foreground">
        Sorry, we couldn’t find the page you’re looking for.
      </p>
      <Button asChild className="mt-6">
        <Link to="/">Go Home</Link>
      </Button>
    </div>
  );
}
