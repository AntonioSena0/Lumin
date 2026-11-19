"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import Link from "next/link";
import { Download } from "lucide-react";
import { links, type Dict, type Lang } from "@/lib/content";

/** Salva o idioma escolhido para o proxy respeitar nas próximas visitas, acima da detecção por região. */
function rememberLang(value: Lang) {
  document.cookie = `lang=${value};path=/;max-age=31536000;samesite=lax`;
}

/** Barra fixa com navegação, troca de idioma (salva em cookie) e progresso de leitura da página. */
export default function Header({ lang, t }: { lang: Lang; t: Dict["nav"] }) {
  const bar = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const update = () => {
      const max = document.documentElement.scrollHeight - innerHeight;
      if (bar.current) bar.current.style.transform = `scaleX(${max > 0 ? scrollY / max : 0})`;
    };
    update();
    addEventListener("scroll", update, { passive: true });
    return () => removeEventListener("scroll", update);
  }, []);

  return (
    <header className="fixed inset-x-0 top-0 z-50">
      <div className="glass mx-auto mt-3 flex h-14 w-[min(1180px,calc(100%-24px))] items-center justify-between gap-3 rounded-full pl-3 pr-2">
        <a href="#inicio" className="flex items-center gap-2 font-display text-lg font-bold">
          <Image src="/brand/logo.png" alt="" width={34} height={34} priority />
          Lumin
        </a>
        <nav aria-label={lang === "pt" ? "Seções" : "Sections"} className="hidden items-center gap-6 text-sm text-haze lg:flex">
          <a href="#como-funciona" className="transition-colors hover:text-mist">{t.how}</a>
          <a href="#exercicios" className="transition-colors hover:text-mist">{t.exercises}</a>
          <a href="#telas" className="transition-colors hover:text-mist">{t.screens}</a>
          <a href="#equipe" className="transition-colors hover:text-mist">{t.team}</a>
          <a href="#duvidas" className="transition-colors hover:text-mist">{t.faq}</a>
        </nav>
        <div className="flex items-center gap-2">
          <div role="group" aria-label={t.lang} className="flex rounded-full bg-white/5 p-1 text-xs font-semibold">
            {(["pt", "en"] as const).map((value) => (
              <Link
                key={value}
                href={`/${value}`}
                onClick={() => rememberLang(value)}
                aria-current={value === lang ? "true" : undefined}
                className={`rounded-full px-2.5 py-1.5 uppercase transition-colors ${value === lang ? "bg-mist text-night" : "text-haze hover:text-mist"}`}
              >
                {value}
              </Link>
            ))}
          </div>
          <a
            href={links.apk}
            aria-label={t.cta}
            className="flex items-center gap-2 rounded-full bg-violet px-4 py-2.5 text-sm font-semibold shadow-[0_0_24px_rgba(208,0,217,0.45)] transition-transform hover:scale-[1.04]"
          >
            <Download size={16} aria-hidden />
            <span className="hidden sm:inline">{t.cta}</span>
          </a>
        </div>
      </div>
      <div ref={bar} className="mx-auto mt-2 h-[2px] w-[min(1180px,calc(100%-24px))] origin-left scale-x-0 bg-magenta" />
    </header>
  );
}
