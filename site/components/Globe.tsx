"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { createGlobeScene } from "@/lib/globeScene";
import { wordPairs, type Dict, type Lang } from "@/lib/content";

/** Seção do planeta 3D: o globo gira com o scroll, com pares de palavras reais orbitando e o contador de objetos. */
export default function Globe({ lang, t }: { lang: Lang; t: Dict["globe"] }) {
  const root = useRef<HTMLElement>(null);
  const canvas = useRef<HTMLCanvasElement>(null);
  const labels = useRef<HTMLSpanElement[]>([]);
  const counter = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    if (!root.current || !canvas.current) return;
    gsap.registerPlugin(ScrollTrigger);
    const scene = createGlobeScene(canvas.current, labels.current);
    const q = gsap.utils.selector(root);
    const count = { value: 0 };

    const ctx = gsap.context(() => {
      gsap.to(scene.state, {
        progress: 1,
        ease: "none",
        scrollTrigger: { trigger: root.current, start: "top bottom", end: "bottom top", scrub: 0.8 },
      });
      gsap.from(q(".globe-copy > *"), {
        y: 50,
        autoAlpha: 0,
        stagger: 0.12,
        duration: 1,
        ease: "power3.out",
        scrollTrigger: { trigger: root.current, start: "top 55%" },
      });
      gsap.to(count, {
        value: 439,
        duration: 2.2,
        ease: "power2.out",
        scrollTrigger: { trigger: root.current, start: "top 55%" },
        onUpdate: () => {
          if (counter.current) counter.current.textContent = String(Math.round(count.value));
        },
      });
    }, root);

    return () => {
      ctx.revert();
      scene.dispose();
    };
  }, []);

  return (
    <section ref={root} className="relative h-[200vh]" aria-labelledby="globe-title">
      <div className="sticky top-0 h-svh overflow-hidden">
        <canvas ref={canvas} className="absolute inset-0 h-full w-full" aria-hidden />
        <div aria-hidden className="absolute inset-0">
          {wordPairs.map(([pt, en], i) => (
            <span
              key={en}
              ref={(el) => {
                if (el) labels.current[i] = el;
              }}
              className="glass absolute left-0 top-0 whitespace-nowrap rounded-full px-3 py-1.5 text-xs font-semibold opacity-0 will-change-transform"
            >
              {lang === "pt" ? pt : en}
              <span className="text-scan"> → {lang === "pt" ? en : pt}</span>
            </span>
          ))}
        </div>
        <div className="globe-copy relative mx-auto flex h-full max-w-6xl flex-col justify-start px-6 pt-28 md:justify-center md:pt-0">
          <p className="font-display text-[clamp(4.5rem,13vw,10rem)] font-extrabold leading-none" aria-hidden>
            <span ref={counter}>0</span>
          </p>
          <h2 id="globe-title" className="mt-2 max-w-md font-display text-[clamp(1.7rem,3.6vw,2.8rem)] font-bold leading-tight">
            {t.title}
          </h2>
          <p className="mt-4 max-w-sm leading-relaxed text-haze">{t.text}</p>
          <p className="mt-6 max-w-sm text-sm text-haze/80">{t.hint}</p>
        </div>
      </div>
    </section>
  );
}
