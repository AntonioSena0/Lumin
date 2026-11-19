"use client";

import Image from "next/image";
import type { PointerEvent } from "react";
import { team, type Dict, type Lang } from "@/lib/content";

/** Inclina o card em 3D seguindo o ponteiro. */
function tilt(e: PointerEvent<HTMLElement>) {
  const el = e.currentTarget;
  const r = el.getBoundingClientRect();
  const x = (e.clientX - r.left) / r.width - 0.5;
  const y = (e.clientY - r.top) / r.height - 0.5;
  el.style.transform = `rotateY(${x * 16}deg) rotateX(${-y * 16}deg) translateZ(10px)`;
}

/** Volta o card para a posição neutra quando o ponteiro sai. */
function reset(e: PointerEvent<HTMLElement>) {
  e.currentTarget.style.transform = "";
}

/** Equipe do projeto com foto, papel no TCC e links do GitHub e do LinkedIn, em cards com inclinação 3D. */
export default function Team({ lang, t }: { lang: Lang; t: Dict["team"] }) {
  return (
    <section id="equipe" className="mx-auto max-w-6xl px-6 pb-32" aria-labelledby="team-title">
      <h2 id="team-title" className="font-display text-[clamp(2.2rem,5vw,3.8rem)] font-extrabold">
        {t.title}
      </h2>
      <p className="mt-3 text-haze">{t.text}</p>
      <ul className="mt-12 grid grid-cols-2 gap-5 lg:grid-cols-4 [perspective:1200px]">
        {team.map((p) => (
          <li key={p.github}>
            <article
              onPointerMove={tilt}
              onPointerLeave={reset}
              className="glass group relative h-full overflow-hidden rounded-[28px] p-3 transition-transform duration-200 ease-out [transform-style:preserve-3d]"
            >
              <div className="relative aspect-square overflow-hidden rounded-[20px]">
                <Image src={p.photo} alt={p.name} fill sizes="(min-width:1024px) 260px, 45vw" className="object-cover transition-transform duration-500 group-hover:scale-105" />
              </div>
              <div className="relative px-1 pb-1 pt-4">
                <p className="font-display text-lg font-bold leading-tight">{p.name}</p>
                <p className="mt-1 text-sm text-haze">{p.role[lang]}</p>
                <div className="mt-3 flex gap-3 text-sm">
                  <a href={`https://github.com/${p.github}`} target="_blank" rel="noreferrer" className="text-scan hover:underline">
                    GitHub
                  </a>
                  <a href={p.linkedin} target="_blank" rel="noreferrer" className="text-scan hover:underline">
                    LinkedIn
                  </a>
                </div>
              </div>
            </article>
          </li>
        ))}
      </ul>
    </section>
  );
}
