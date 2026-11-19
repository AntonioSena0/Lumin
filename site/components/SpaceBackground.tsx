"use client";

import { useEffect, useRef } from "react";

type Star = { x: number; y: number; r: number; depth: number; phase: number };
type Sparkle = { x: number; y: number; size: number; phase: number; hue: string };

/** Fundo fixo inspirado na logo: estrelas em camadas com parallax, brilhos de 4 pontas, estrelas cadentes e anel de órbita. */
export default function SpaceBackground() {
  const canvas = useRef<HTMLCanvasElement>(null);
  const ring = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = canvas.current;
    const ctx = el?.getContext("2d");
    if (!el || !ctx) return;
    const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const dpr = Math.min(devicePixelRatio, 1.5);
    let w = 0;
    let h = 0;
    let stars: Star[] = [];
    let sparkles: Sparkle[] = [];
    let shooting: { x: number; y: number; vx: number; vy: number; life: number } | null = null;
    let frame = 0;

    const build = () => {
      w = innerWidth;
      h = innerHeight;
      el.width = w * dpr;
      el.height = h * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      const count = Math.round((w * h) / 5200);
      stars = Array.from({ length: count }, () => ({
        x: Math.random() * w,
        y: Math.random() * h * 3,
        r: Math.random() * 1.2 + 0.2,
        depth: [0.05, 0.15, 0.3][Math.floor(Math.random() * 3)],
        phase: Math.random() * Math.PI * 2,
      }));
      sparkles = Array.from({ length: 9 }, () => ({
        x: Math.random() * w,
        y: Math.random() * h * 3,
        size: Math.random() * 7 + 5,
        phase: Math.random() * Math.PI * 2,
        hue: Math.random() > 0.5 ? "#d000d9" : "#8f6bff",
      }));
    };

    const sparkle = (x: number, y: number, s: number, color: string, alpha: number) => {
      ctx.save();
      ctx.globalAlpha = alpha;
      ctx.fillStyle = color;
      ctx.shadowColor = color;
      ctx.shadowBlur = 14;
      ctx.beginPath();
      ctx.moveTo(x, y - s);
      ctx.quadraticCurveTo(x, y, x + s, y);
      ctx.quadraticCurveTo(x, y, x, y + s);
      ctx.quadraticCurveTo(x, y, x - s, y);
      ctx.quadraticCurveTo(x, y, x, y - s);
      ctx.fill();
      ctx.restore();
    };

    const draw = (t: number) => {
      const scroll = scrollY;
      ctx.clearRect(0, 0, w, h);
      for (const s of stars) {
        const y = (((s.y - scroll * s.depth) % (h * 3)) + h * 3) % (h * 3);
        if (y > h) continue;
        ctx.globalAlpha = 0.35 + 0.65 * Math.abs(Math.sin(t / 1600 + s.phase));
        ctx.fillStyle = s.depth > 0.2 ? "#f6f0ff" : "#b9a7ff";
        ctx.beginPath();
        ctx.arc(s.x, y, s.r * (1 + s.depth * 2), 0, Math.PI * 2);
        ctx.fill();
      }
      for (const s of sparkles) {
        const y = (((s.y - scroll * 0.22) % (h * 3)) + h * 3) % (h * 3);
        if (y > h) continue;
        sparkle(s.x, y, s.size * (0.8 + 0.25 * Math.sin(t / 900 + s.phase)), s.hue, 0.55 + 0.35 * Math.sin(t / 1300 + s.phase));
      }
      if (!shooting && Math.random() < 0.004) {
        shooting = { x: Math.random() * w, y: Math.random() * h * 0.5, vx: -7 - Math.random() * 4, vy: 3 + Math.random() * 2, life: 1 };
      }
      if (shooting) {
        const g = ctx.createLinearGradient(shooting.x, shooting.y, shooting.x - shooting.vx * 14, shooting.y - shooting.vy * 14);
        g.addColorStop(0, `rgba(82,231,255,${shooting.life})`);
        g.addColorStop(1, "rgba(82,231,255,0)");
        ctx.globalAlpha = 1;
        ctx.strokeStyle = g;
        ctx.lineWidth = 1.6;
        ctx.beginPath();
        ctx.moveTo(shooting.x, shooting.y);
        ctx.lineTo(shooting.x - shooting.vx * 14, shooting.y - shooting.vy * 14);
        ctx.stroke();
        shooting.x += shooting.vx;
        shooting.y += shooting.vy;
        shooting.life -= 0.012;
        if (shooting.life <= 0) shooting = null;
      }
      if (ring.current) ring.current.style.transform = `translate(-50%, -50%) rotate(${scroll * 0.03 + t / 400}deg)`;
    };

    const loop = (t: number) => {
      draw(t);
      frame = requestAnimationFrame(loop);
    };

    build();
    if (reduced) draw(0);
    else frame = requestAnimationFrame(loop);
    addEventListener("resize", build);
    return () => {
      cancelAnimationFrame(frame);
      removeEventListener("resize", build);
    };
  }, []);

  return (
    <div aria-hidden className="pointer-events-none fixed inset-0 -z-10 overflow-hidden bg-night">
      <div
        ref={ring}
        className="orbit-ring absolute left-1/2 top-1/2 h-[118vmax] w-[118vmax] rounded-full opacity-30"
      />
      <canvas ref={canvas} className="absolute inset-0 h-full w-full" />
    </div>
  );
}
