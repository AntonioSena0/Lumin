"use client";

import { useEffect, useRef } from "react";

const CLICKABLE = "a, button, summary, label, input, textarea, select, [role='button']";

/** Mini bolinha que segue o mouse e, sobre algo clicável, cresce e vira uma lente que desfoca o que está embaixo. */
export default function Cursor() {
  const dot = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = dot.current;
    if (!el || !matchMedia("(pointer: fine)").matches) return;
    const ease = matchMedia("(prefers-reduced-motion: reduce)").matches ? 1 : 0.22;
    const target = { x: innerWidth / 2, y: innerHeight / 2 };
    const pos = { ...target };
    let frame = 0;

    const move = (e: PointerEvent) => {
      target.x = e.clientX;
      target.y = e.clientY;
      el.classList.add("is-visible");
    };
    const over = (e: PointerEvent) => {
      el.classList.toggle("is-hover", Boolean((e.target as Element | null)?.closest?.(CLICKABLE)));
    };
    const leave = () => el.classList.remove("is-visible");
    const loop = () => {
      pos.x += (target.x - pos.x) * ease;
      pos.y += (target.y - pos.y) * ease;
      el.style.transform = `translate(${pos.x}px, ${pos.y}px) translate(-50%, -50%)`;
      frame = requestAnimationFrame(loop);
    };

    addEventListener("pointermove", move, { passive: true });
    addEventListener("pointerover", over, { passive: true });
    document.documentElement.addEventListener("pointerleave", leave);
    frame = requestAnimationFrame(loop);
    return () => {
      cancelAnimationFrame(frame);
      removeEventListener("pointermove", move);
      removeEventListener("pointerover", over);
      document.documentElement.removeEventListener("pointerleave", leave);
    };
  }, []);

  return <div ref={dot} aria-hidden className="cursor-dot" />;
}
