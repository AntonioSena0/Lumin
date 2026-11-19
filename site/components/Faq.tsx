"use client";

import { useId, useState } from "react";
import { Plus } from "lucide-react";
import type { Dict } from "@/lib/content";

/** Perguntas frequentes em acordeão: todas começam fechadas e só uma fica aberta por vez, com altura animada. */
export default function Faq({ t }: { t: Dict["faq"] }) {
  const [open, setOpen] = useState<number | null>(null);
  const id = useId();

  return (
    <section id="duvidas" className="mx-auto max-w-3xl px-6 py-32" aria-labelledby="faq-title">
      <h2 id="faq-title" className="font-display text-[clamp(2.2rem,5vw,3.8rem)] font-extrabold">
        {t.title}
      </h2>
      <div className="mt-10 space-y-3">
        {t.items.map(([question, answer], i) => {
          const isOpen = open === i;
          return (
            <div key={question} className={`glass rounded-3xl transition-colors ${isOpen ? "border-magenta/50" : ""}`}>
              <h3>
                <button
                  type="button"
                  aria-expanded={isOpen}
                  aria-controls={`${id}-${i}`}
                  onClick={() => setOpen(isOpen ? null : i)}
                  className="flex w-full items-center justify-between gap-6 px-6 py-5 text-left font-display text-lg font-bold"
                >
                  {question}
                  <Plus
                    size={22}
                    aria-hidden
                    className={`shrink-0 text-magenta transition-transform duration-300 ${isOpen ? "rotate-45" : ""}`}
                  />
                </button>
              </h3>
              <div
                id={`${id}-${i}`}
                role="region"
                className={`grid transition-[grid-template-rows] duration-300 ease-out ${isOpen ? "grid-rows-[1fr]" : "grid-rows-[0fr]"}`}
              >
                <div className="overflow-hidden">
                  <p className={`px-6 pb-6 leading-relaxed text-haze transition-opacity duration-300 ${isOpen ? "opacity-100" : "opacity-0"}`}>{answer}</p>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}
