"use client";

import { useEffect } from "react";
import Lenis from "lenis";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

/** Liga o Lenis ao relógio do GSAP para o hero fixado acompanhar o scroll suave, exceto com movimento reduzido. */
export default function SmoothScroll() {
  useEffect(() => {
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    gsap.registerPlugin(ScrollTrigger);
    const lenis = new Lenis({ duration: 1.1, easing: (t) => 1 - Math.pow(1 - t, 4), anchors: { offset: -72 } });
    lenis.on("scroll", ScrollTrigger.update);
    const ready = () => lenis.start();
    if (!(window as Window & { luminReady?: boolean }).luminReady) {
      lenis.stop();
      addEventListener("lumin:ready", ready, { once: true });
    }
    const tick = (t: number) => lenis.raf(t * 1000);
    gsap.ticker.add(tick);
    gsap.ticker.lagSmoothing(0);
    return () => {
      removeEventListener("lumin:ready", ready);
      gsap.ticker.remove(tick);
      lenis.destroy();
    };
  }, []);
  return null;
}
