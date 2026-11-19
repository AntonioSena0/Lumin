import Link from "next/link";

/** Página 404 bilíngue com atalho de volta para o início. */
export default function NotFound() {
  return (
    <main className="flex min-h-svh flex-col items-center justify-center gap-6 px-6 text-center">
      <p className="font-display text-8xl font-extrabold">404</p>
      <p className="text-haze">Página não encontrada. Page not found.</p>
      <Link href="/" className="rounded-full bg-mist px-6 py-3 font-semibold text-night">
        Lumin
      </Link>
    </main>
  );
}
