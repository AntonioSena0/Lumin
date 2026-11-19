"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { CheckCircle2, Gauge, Languages } from "lucide-react";
import type { Dict } from "@/lib/content";

/** Demonstração guiada pelo scroll do exercício de montar a tradução, com os tipos de exercício acendendo em sequência. */
export default function ExerciseDemo({ t }: { t: Dict["exercises"] }) {
  const root = useRef<HTMLElement>(null);
  const bank = [3, 4, 5, -1, 0, 1, 2, -2].map((i) =>
    i >= 0 ? { word: t.demoBlocks[i], index: i } : { word: t.demoDistractors[-i - 1], index: undefined },
  );

  useEffect(() => {
    if (!root.current) return;
    gsap.registerPlugin(ScrollTrigger);
    const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const q = gsap.utils.selector(root);
    const ctx = gsap.context(() => {
      const wide = innerWidth >= 768;
      const tl = gsap.timeline({
        defaults: { ease: "power2.out" },
        scrollTrigger: reduced
          ? undefined
          : wide
            ? { trigger: root.current, start: "top top", end: "bottom bottom", scrub: 0.6 }
            : { trigger: root.current, start: "top 65%" },
      });
      if (!wide) tl.timeScale(0.35);
      t.demoBlocks.forEach((_, i) => {
        const at = i * 0.12;
        tl.to(q(`[data-bank="${i}"]`), { autoAlpha: 0.15, scale: 0.85, duration: 0.08 }, at)
          .fromTo(q(`[data-placed="${i}"]`), { y: 140, x: () => gsap.utils.random(-80, 80), rotate: () => gsap.utils.random(-25, 25), autoAlpha: 0 }, { y: 0, x: 0, rotate: 0, autoAlpha: 1, duration: 0.12, ease: "back.out(1.6)" }, at);
      });
      tl.fromTo(q(".demo-progress"), { scaleX: 0.1 }, { scaleX: 1, duration: 0.8, ease: "none" }, 0)
        .from(q(".demo-feedback"), { y: 40, autoAlpha: 0, scale: 0.9, duration: 0.12, ease: "back.out(2)" }, 0.78);
      q(".type-item").forEach((item: Element, i: number) => {
        tl.fromTo(item, { opacity: 0.35 }, { opacity: 1, duration: 0.08 }, i * 0.17);
        tl.fromTo(item.querySelector(".type-dot"), { scale: 0 }, { scale: 1, duration: 0.06 }, i * 0.17);
      });
      if (reduced) tl.progress(1);
    }, root);
    return () => ctx.revert();
  }, [t.demoBlocks]);

  return (
    <section ref={root} id="exercicios" className="relative md:h-[240vh] motion-reduce:h-auto" aria-labelledby="exercises-title">
      <div className="mx-auto grid max-w-6xl items-center gap-10 px-6 py-24 md:sticky md:top-0 md:min-h-svh md:grid-cols-[1fr_1fr] md:gap-12 md:pb-10">
        <div className="glass order-last mx-auto w-full max-w-[400px] rounded-[32px] p-5 md:order-none shadow-[0_30px_120px_-30px_rgba(106,0,244,0.8)]">
          <div className="h-2.5 overflow-hidden rounded-full bg-white/10">
            <div className="demo-progress h-full origin-left rounded-full bg-magenta" />
          </div>
          <p className="mt-6 inline-flex items-center gap-1.5 rounded-full bg-violet/25 px-3 py-1 text-xs font-semibold">
            <Languages size={14} className="text-scan" aria-hidden />
            {t.demoLabel}
          </p>
          <p className="mt-4 font-display text-2xl font-bold">{t.demoPrompt}</p>
          <div className="mt-6 flex min-h-[104px] flex-wrap content-start gap-2 rounded-2xl border border-violet/70 p-3">
            {t.demoBlocks.map((word, i) => (
              <span key={`p${i}`} data-placed={i} className="rounded-xl border-b-[3px] border-magenta bg-violet px-3.5 py-2 font-semibold">
                {word}
              </span>
            ))}
          </div>
          <div className="mt-5 flex flex-wrap justify-center gap-2">
            {bank.map(({ word, index }, i) => (
              <span key={`b${i}`} data-bank={index} className="rounded-xl border-b-[3px] border-black/50 bg-white/10 px-3.5 py-2 font-semibold">
                {word}
              </span>
            ))}
          </div>
          <div className="demo-feedback mt-5 flex items-center gap-2 rounded-2xl border border-[#2bd98f]/60 bg-[#2bd98f]/12 px-4 py-3 font-bold text-[#2bd98f]">
            <CheckCircle2 size={20} aria-hidden />
            {t.correct}
          </div>
        </div>

        <div>
          <h2 id="exercises-title" className="font-display text-[clamp(2.2rem,5vw,3.8rem)] font-extrabold leading-[1]">
            {t.title}
          </h2>
          <p className="mt-5 max-w-md text-lg leading-relaxed text-haze">{t.text}</p>
          <ul className="mt-6 space-y-3">
            {t.types.map(([title, text]) => (
              <li key={title} className="type-item flex gap-3">
                <span className="type-dot mt-2 h-2.5 w-2.5 shrink-0 rounded-full bg-scan shadow-[0_0_12px_#52e7ff]" />
                <span>
                  <span className="block font-semibold">{title}</span>
                  <span className="text-sm text-haze">{text}</span>
                </span>
              </li>
            ))}
          </ul>
          <div className="glass mt-6 flex items-center gap-4 rounded-3xl p-4">
            <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-violet">
              <Gauge size={28} aria-hidden />
            </div>
            <div>
              <p className="font-semibold">{t.levelTitle}</p>
              <p className="text-sm text-haze">{t.levelText}</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
