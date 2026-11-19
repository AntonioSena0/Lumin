"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import { Plus, Search, Star } from "lucide-react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { wordPairs, type Dict } from "@/lib/content";

/** Recursos sociais: no desktop as cartas se abrem em leque 3D com o scroll; no mobile deslizam na horizontal com o scroll. */
export default function Community({ t }: { t: Dict["community"] }) {
  const root = useRef<HTMLElement>(null);

  useEffect(() => {
    if (!root.current) return;
    gsap.registerPlugin(ScrollTrigger);
    const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const q = gsap.utils.selector(root);
    const ctx = gsap.context(() => {
      const wide = innerWidth >= 768;
      if (!wide) {
        if (reduced) return;
        const row = q(".comm-row")[0] as HTMLElement;
        const distance = () => Math.max(0, row.scrollWidth - innerWidth);
        gsap
          .timeline({
            scrollTrigger: { trigger: root.current, start: "top top", end: () => `+=${distance() * 1.8}`, pin: true, scrub: 0.8, invalidateOnRefresh: true },
          })
          .to(row, { x: () => -distance(), ease: "none", duration: 1 }, 0.3)
          .to({}, { duration: 0.3 });
        return;
      }
      const tl = gsap.timeline({
        defaults: { ease: "power2.inOut" },
        scrollTrigger: reduced ? undefined : { trigger: root.current, start: "top top", end: "bottom bottom", scrub: 0.8 },
      });
      q(".deck-card").forEach((card: Element, i: number) => {
        const offset = i - 1;
        tl.fromTo(
          card,
          { x: 0, y: offset * -14, rotateZ: offset * 4, rotateY: 0, z: -i * 30 },
          { x: wide ? `${offset * 112}%` : 0, y: wide ? Math.abs(offset) * 30 : offset * 0, rotateZ: offset * 7, rotateY: offset * -18, z: 0, duration: 0.5 },
          0,
        );
      });
      q(".deck-copy").forEach((copy: Element, i: number) => {
        tl.from(copy, { y: 40, autoAlpha: 0, duration: 0.15 }, 0.45 + i * 0.12);
      });
      if (reduced) tl.progress(1);
    }, root);
    return () => ctx.revert();
  }, []);

  return (
    <section ref={root} className="relative md:h-[220vh] motion-reduce:h-auto" aria-labelledby="community-title">
      <div className="mx-auto flex min-h-svh max-w-6xl flex-col justify-center pb-6 pt-20 md:sticky md:top-0 md:px-6 md:py-20">
        <h2 id="community-title" className="px-6 text-center font-display text-[clamp(2.2rem,5vw,3.8rem)] font-extrabold">
          {t.title}
        </h2>
        <div className="mt-8 overflow-hidden motion-reduce:overflow-x-auto md:hidden">
          <div className="comm-row flex w-max gap-4 px-6 pb-4">
            {t.items.map((item, i) => (
              <div key={item.title} className="w-[min(78vw,320px,calc((100svh-330px)*9/14))] shrink-0">
                <div className="glass flex aspect-[9/14] flex-col justify-center overflow-hidden rounded-[28px] p-4 text-sm">
                  <CommunityVisual index={i} d={t.demo} />
                </div>
                <h3 className="mt-5 font-display text-xl font-bold">{item.title}</h3>
                <p className="mt-1 text-sm leading-relaxed text-haze">{item.text}</p>
              </div>
            ))}
          </div>
        </div>
        <div className="relative mx-auto mt-12 hidden h-[min(46svh,420px)] w-full items-center justify-center [perspective:1400px] md:flex">
          {t.items.map((item, i) => (
            <div
              key={item.title}
              className="deck-card glass absolute flex aspect-[9/14] h-full flex-col justify-center overflow-hidden rounded-[28px] p-4 text-sm shadow-[0_30px_80px_-20px_rgba(106,0,244,0.7)]"
              style={{ zIndex: i === 1 ? 3 : 2 - i }}
            >
              <CommunityVisual index={i} d={t.demo} />
            </div>
          ))}
        </div>
        <div className="mt-12 hidden gap-8 md:grid md:grid-cols-3">
          {t.items.map((item) => (
            <div key={item.title} className="deck-copy text-center">
              <h3 className="font-display text-2xl font-bold">{item.title}</h3>
              <p className="mx-auto mt-2 max-w-xs leading-relaxed text-haze">{item.text}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/** Mini interface própria de cada recurso social: busca na comunidade, perfil para seguir e histórico. */
function CommunityVisual({ index, d }: { index: number; d: Dict["community"]["demo"] }) {
  if (index === 0) {
    return (
      <div className="space-y-3">
        <p className="flex items-center gap-2 rounded-xl bg-white/10 px-3 py-2.5">
          <Search size={16} className="text-haze" aria-hidden />
          {d.search}
        </p>
        <div className="flex gap-2 text-xs">
          <span className="rounded-full bg-white/10 px-3 py-1">{d.all}</span>
          <span className="rounded-full bg-magenta px-3 py-1 font-semibold">{d.category}</span>
        </div>
        {d.results.map(([from, to]) => (
          <p key={from} className="flex items-center justify-between rounded-xl bg-white/10 px-3 py-2">
            <span>
              {from} <span className="text-scan">→ {to}</span>
            </span>
            <Plus size={18} className="rounded-full bg-violet p-0.5" aria-hidden />
          </p>
        ))}
      </div>
    );
  }
  if (index === 1) {
    return (
      <div className="flex flex-col items-center text-center">
        <Image src="/avatars/pixel/white_woman.png" alt="" width={96} height={96} unoptimized className="rounded-full [image-rendering:pixelated]" />
        <p className="mt-3 font-display text-xl font-bold">{d.name}</p>
        <p className="text-xs text-magenta">{d.level}</p>
        <p className="mt-4 text-xs text-haze">{d.followers}</p>
        <div className="mt-1 flex -space-x-2">
          {["black_man", "asian_woman", "braids_woman", "elder_man"].map((a) => (
            <Image key={a} src={`/avatars/pixel/${a}.png`} alt="" width={34} height={34} unoptimized className="rounded-full ring-2 ring-dusk [image-rendering:pixelated]" />
          ))}
        </div>
        <p className="mt-5 w-full rounded-xl bg-violet py-2.5 font-semibold">{d.follow}</p>
      </div>
    );
  }
  return (
    <div className="space-y-2.5">
      <p className="mb-1 font-display text-lg font-bold">{d.history}</p>
      {[0, 1, 2, 12, 14].map((i) => wordPairs[i]).map(([pt, en]) => (
        <p key={en} className="flex items-center justify-between rounded-xl bg-white/10 px-3 py-2">
          <span className="flex items-center gap-2">
            <Image src="/flags/br.png" alt="" width={18} height={12} className="h-[12px] w-[18px] object-cover rounded-[2px]" />
            {pt} <span className="text-scan">→ {en}</span>
          </span>
          <Star size={14} className="text-[#ffc83d]" fill="#ffc83d" aria-hidden />
        </p>
      ))}
    </div>
  );
}
