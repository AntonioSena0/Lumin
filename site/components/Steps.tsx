"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import type { Dict } from "@/lib/content";

const screens = ["/screens/camera.webp", "/screens/salvar.webp", "/screens/detalhes.webp"];

/** Passos do app: no desktop em scroll horizontal fixado com celulares girando em 3D; no mobile em lista vertical. */
export default function Steps({ t }: { t: Dict["steps"] }) {
  const root = useRef<HTMLElement>(null);
  const track = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!root.current || !track.current) return;
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    gsap.registerPlugin(ScrollTrigger);
    const ctx = gsap.matchMedia(root);
    ctx.add("(min-width: 768px)", () => {
      const distance = () => track.current!.scrollWidth - innerWidth;
      const slide = gsap.to(track.current, {
        x: () => -distance(),
        ease: "none",
        scrollTrigger: {
          trigger: root.current,
          start: "top top",
          end: () => `+=${distance()}`,
          pin: true,
          scrub: 0.8,
          invalidateOnRefresh: true,
        },
      });
      gsap.utils.toArray<HTMLElement>(".step-phone").forEach((phone) => {
        gsap.fromTo(
          phone,
          { rotateY: -38, rotateX: 8, scale: 0.85 },
          {
            rotateY: 0,
            rotateX: 0,
            scale: 1,
            ease: "none",
            scrollTrigger: { trigger: phone, containerAnimation: slide, start: "left right", end: "center center", scrub: true },
          },
        );
      });
      gsap.utils.toArray<HTMLElement>(".step-copy").forEach((copy) => {
        gsap.from(copy, {
          y: 60,
          autoAlpha: 0,
          ease: "power2.out",
          scrollTrigger: { trigger: copy, containerAnimation: slide, start: "left 80%", end: "left 40%", scrub: true },
        });
      });
    });
    ctx.add("(max-width: 767px)", () => {
      gsap.utils.toArray<HTMLElement>(".step-item").forEach((item) => {
        gsap.from(item, { y: 60, autoAlpha: 0, duration: 0.8, ease: "power3.out", scrollTrigger: { trigger: item, start: "top 85%" } });
      });
    });
    return () => ctx.revert();
  }, []);

  return (
    <section ref={root} id="como-funciona" className="relative overflow-hidden" aria-labelledby="steps-title">
      <div ref={track} className="flex flex-col gap-16 px-6 py-24 md:min-h-svh md:w-max md:flex-row md:items-center md:gap-[8vw] md:px-[6vw] motion-reduce:md:w-full motion-reduce:md:flex-col">
        <div className="shrink-0 md:w-[min(82vw,520px)]">
          <h2 id="steps-title" className="font-display text-[clamp(2.4rem,6vw,4.6rem)] font-extrabold leading-[0.95]">
            {t.title}
          </h2>
        </div>
        {t.items.map((item, i) => (
          <article key={item.title} className="step-item flex shrink-0 flex-col items-center gap-8 md:w-[min(86vw,900px)] md:flex-row md:gap-10">
            <div className="[perspective:1000px]">
              <div className="step-phone relative aspect-[378/640] w-[min(62vw,260px)] overflow-hidden rounded-[32px] border-[8px] border-[#1d1230] shadow-[0_30px_100px_-20px_rgba(208,0,217,0.55)] ring-1 ring-white/10">
                <Image src={screens[i]} alt="" fill sizes="260px" className="object-cover" />
              </div>
            </div>
            <div className="step-copy w-full max-w-sm">
              <span className="font-display text-7xl font-extrabold md:text-8xl text-transparent [-webkit-text-stroke:1.5px_var(--color-magenta)]">{i + 1}</span>
              <h3 className="mt-2 font-display text-3xl font-bold">{item.title}</h3>
              <p className="mt-3 text-lg leading-relaxed text-haze">{item.text}</p>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

