"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import type { Dict } from "@/lib/content";

/** Carrossel cilíndrico 3D com as telas reais do app, girado pelo scroll e pelo arraste do usuário. */
export default function ScreensRing({ t }: { t: Dict["screens"] }) {
  const root = useRef<HTMLElement>(null);
  const ring = useRef<HTMLDivElement>(null);
  const [active, setActive] = useState(0);
  const step = 360 / t.items.length;

  useEffect(() => {
    if (!root.current || !ring.current) return;
    gsap.registerPlugin(ScrollTrigger);
    const scrolled = { angle: 0 };
    let drag = 0;
    let startX: number | null = null;
    let startDrag = 0;

    const apply = () => {
      const angle = scrolled.angle + drag;
      ring.current!.style.transform = `translateZ(calc(var(--radius) * -1)) rotateY(${angle}deg)`;
      const index = ((Math.round(-angle / step) % t.items.length) + t.items.length) % t.items.length;
      setActive((current) => (current === index ? current : index));
    };

    const tween = gsap.to(scrolled, {
      angle: -360 + step,
      ease: "none",
      scrollTrigger: { trigger: root.current, start: "top top", end: "bottom bottom", scrub: 1 },
      onUpdate: apply,
    });

    const down = (e: PointerEvent) => {
      startX = e.clientX;
      startDrag = drag;
    };
    const move = (e: PointerEvent) => {
      if (startX === null) return;
      drag = startDrag + (e.clientX - startX) * 0.25;
      apply();
    };
    const up = () => {
      if (startX === null) return;
      startX = null;
      const target = Math.round((scrolled.angle + drag) / step) * step - scrolled.angle;
      gsap.to({ value: drag }, { value: target, duration: 0.5, ease: "power3.out", onUpdate() { drag = this.targets()[0].value; apply(); } });
    };

    const el = ring.current.parentElement!;
    el.addEventListener("pointerdown", down);
    addEventListener("pointermove", move);
    addEventListener("pointerup", up);
    apply();
    return () => {
      tween.scrollTrigger?.kill();
      tween.kill();
      el.removeEventListener("pointerdown", down);
      removeEventListener("pointermove", move);
      removeEventListener("pointerup", up);
    };
  }, [step, t.items.length]);

  return (
    <section ref={root} id="telas" className="relative h-[260vh] motion-reduce:h-auto" aria-labelledby="screens-title">
      <div className="sticky top-0 flex h-svh flex-col items-center justify-center overflow-hidden">
        <h2 id="screens-title" className="px-6 text-center font-display text-[clamp(2.2rem,5vw,3.8rem)] font-extrabold">
          {t.title}
        </h2>
        <p className="mt-2 text-sm text-haze">{t.text}</p>
        <div className="relative mt-10 h-[min(44svh,380px)] md:h-[min(56svh,460px)] w-full cursor-grab touch-pan-y select-none [perspective:1800px] active:cursor-grabbing [--radius:440px] md:[--radius:620px]">
          <div ref={ring} className="absolute inset-0 [transform-style:preserve-3d]">
            {t.items.map(([src, label], i) => (
              <figure
                key={src}
                className="absolute left-1/2 top-0 h-full aspect-[378/640] -translate-x-1/2 [backface-visibility:hidden]"
                style={{ transform: `rotateY(${i * step}deg) translateZ(var(--radius))` }}
              >
                <div
                  className={`relative h-full w-full overflow-hidden rounded-[28px] border-[6px] border-[#1d1230] transition-[box-shadow,filter] duration-500 ${i === active ? "shadow-[0_0_60px_rgba(208,0,217,0.6)]" : "brightness-50"}`}
                >
                  <Image src={src} alt={label} fill sizes="280px" className="pointer-events-none object-cover" draggable={false} />
                </div>
              </figure>
            ))}
          </div>
        </div>
        <p aria-live="polite" className="mt-8 font-display text-2xl font-bold">
          {t.items[active][1]}
        </p>
      </div>
    </section>
  );
}
