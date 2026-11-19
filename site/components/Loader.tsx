"use client";

import { useEffect, useState } from "react";

/** Tela de carregamento: um planeta gira e, quando tudo está pronto, vira uma janela circular que cresce e revela o site. */
export default function Loader({ label }: { label: string }) {
  const [phase, setPhase] = useState<"loading" | "opening" | "done">("loading");

  useEffect(() => {
    history.scrollRestoration = "manual";
    scrollTo(0, 0);
    document.documentElement.style.overflow = "hidden";
    const loaded = document.readyState === "complete" ? Promise.resolve() : new Promise((r) => addEventListener("load", r, { once: true }));
    const minimum = new Promise((r) => setTimeout(r, 900));
    let finish: ReturnType<typeof setTimeout>;
    Promise.all([loaded, document.fonts.ready, minimum]).then(() => {
      setPhase("opening");
      document.documentElement.style.overflow = "";
      (window as Window & { luminReady?: boolean }).luminReady = true;
      dispatchEvent(new Event("lumin:ready"));
      finish = setTimeout(() => setPhase("done"), 1300);
    });
    return () => clearTimeout(finish);
  }, []);

  if (phase === "done") return null;
  const opening = phase === "opening";

  return (
    <div role="status" aria-label={label} className={`loader fixed inset-0 z-[100] ${opening ? "loader-open pointer-events-none" : ""}`}>
      <div className="loader-veil absolute inset-0 bg-night" />
      <div className="loader-ring absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full" />
      <div className={`absolute left-1/2 top-1/2 h-28 w-28 -translate-x-1/2 -translate-y-1/2 transition-[opacity,scale] duration-300 ${opening ? "scale-110 opacity-0" : ""}`}>
        <div className="planet absolute inset-0 overflow-hidden rounded-full shadow-[0_0_60px_rgba(166,77,255,0.8),inset_-14px_-10px_30px_rgba(7,1,17,0.9)]" />
        <div className="absolute left-1/2 top-1/2 h-12 w-44 -translate-x-1/2 -translate-y-1/2 -rotate-[18deg] rounded-[50%] border-2 border-magenta/70" />
        <div className="absolute left-1/2 top-1/2 -rotate-[18deg]">
          <span className="moon absolute -left-1.5 -top-1.5 block h-3 w-3 rounded-full bg-scan shadow-[0_0_10px_#52e7ff]" />
        </div>
      </div>
    </div>
  );
}
