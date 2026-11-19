"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { wordPairs, type Dict } from "@/lib/content";

/** Seção do idioma da interface: uma palavra gira em 3D entre português e inglês, alternando pares reais do app. */
export default function Bilingual({ t }: { t: Dict["bilingual"] }) {
  const [step, setStep] = useState(0);

  useEffect(() => {
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const timer = setInterval(() => setStep((s) => s + 1), 1700);
    return () => clearInterval(timer);
  }, []);

  const [pt, en] = wordPairs[Math.floor(step / 2) % wordPairs.length];

  return (
    <section className="mx-auto grid max-w-6xl items-center gap-14 px-6 py-32 md:grid-cols-2" aria-labelledby="bilingual-title">
      <div className="mx-auto [perspective:900px]">
        <div
          className="relative h-56 w-[min(84vw,380px)] transition-transform duration-700 [transform-style:preserve-3d] [transition-timing-function:cubic-bezier(.6,-0.2,.3,1.3)]"
          style={{ transform: `rotateX(${step * 180}deg)` }}
          aria-hidden
        >
          {[
            ["br", pt, 0],
            ["us", en, 180],
          ].map(([flag, word, rotation]) => (
            <div
              key={String(flag)}
              className="glass absolute inset-0 flex flex-col items-center justify-center gap-4 rounded-[32px] px-6 [backface-visibility:hidden]"
              style={{ transform: `rotateX(${rotation}deg)` }}
            >
              <Image src={`/flags/${flag}.png`} alt="" width={48} height={34} className="h-[34px] w-[48px] object-cover rounded-md" />
              <span className="max-w-full text-center font-display text-[clamp(1.7rem,5vw,2.6rem)] font-extrabold leading-tight [overflow-wrap:anywhere] [text-wrap:balance]">{word}</span>
            </div>
          ))}
        </div>
      </div>
      <div>
        <h2 id="bilingual-title" className="font-display text-[clamp(2.2rem,5vw,3.8rem)] font-extrabold leading-[1]">
          {t.title}
        </h2>
        <p className="mt-5 max-w-md text-lg leading-relaxed text-haze">{t.text}</p>
      </div>
    </section>
  );
}
