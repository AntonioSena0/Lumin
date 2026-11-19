"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { ArrowDown, ArrowRight, Download, Volume2 } from "lucide-react";
import { createMugScene } from "@/lib/mugScene";
import { links, type Dict, type Lang } from "@/lib/content";

/** Fala o texto com a síntese de voz do navegador, no idioma informado. */
function speak(text: string, lang: string) {
  if (!("speechSynthesis" in window)) return;
  speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = lang;
  speechSynthesis.speak(utterance);
}

/** Hero fixado no scroll: o celular se aproxima, detecta a caneca 3D e sua moldura se abre no cartão da palavra. */
export default function Hero({ lang, t }: { lang: Lang; t: Dict["hero"] }) {
  const root = useRef<HTMLElement>(null);
  const canvas = useRef<HTMLCanvasElement>(null);
  const native = lang === "pt" ? { flag: "br", word: "caneca" } : { flag: "us", word: "mug" };
  const target = lang === "pt" ? { flag: "us", word: "mug", phonetic: "/mʌɡ/", voice: "en-US" } : { flag: "br", word: "caneca", phonetic: "/kaˈnɛkɐ/", voice: "pt-BR" };
  const exampleVoice = target.voice;

  useEffect(() => {
    if (!root.current || !canvas.current) return;
    const phone = root.current.querySelector<HTMLElement>(".phone");
    if (!phone) return;
    gsap.registerPlugin(ScrollTrigger);
    const scene = createMugScene(canvas.current);
    const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const q = gsap.utils.selector(root);
    let intro: gsap.core.Timeline | undefined;

    const ctx = gsap.context(() => {
      intro = gsap
        .timeline({ paused: true, defaults: { ease: "power3.out" } })
        .fromTo(q(".intro-line"), { yPercent: 110 }, { yPercent: 0, duration: 1, stagger: 0.12 })
        .fromTo(q(".intro-fade"), { y: 20, autoAlpha: 0 }, { y: 0, autoAlpha: 1, duration: 0.8, stagger: 0.1 }, 0.5);

      const wide = innerWidth >= 768;
      const tl = gsap.timeline({
        defaults: { ease: "none" },
        scrollTrigger: reduced ? undefined : { trigger: root.current, start: "top top", end: "bottom bottom", scrub: 0.7 },
      });

      tl.to(scene.state, { progress: 1, duration: 1 }, 0)
        .to(q(".intro"), { yPercent: -25, autoAlpha: 0, duration: 0.14 }, 0.02)
        .fromTo(q(".phone"), { yPercent: 120, rotateX: 28, scale: 0.7 }, { yPercent: 0, rotateX: 0, scale: 1, duration: 0.3, ease: "power2.out" }, 0.08)
        .fromTo(q(".phone-screen"), { "--dim": 0 }, { "--dim": 0.85, duration: 0.26 }, 0.1)
        .fromTo(q(".corner"), { scale: 1.8, autoAlpha: 0 }, { scale: 1, autoAlpha: 1, duration: 0.06, stagger: 0.01 }, 0.36)
        .fromTo(q(".scan-line"), { top: "30%", autoAlpha: 0 }, { top: "66%", autoAlpha: 1, duration: 0.08 }, 0.38)
        .to(q(".scan-line"), { autoAlpha: 0, duration: 0.02 }, 0.46)
        .fromTo(q(".scan-status"), { autoAlpha: 0, y: -8 }, { autoAlpha: 1, y: 0, duration: 0.04 }, 0.44)
        .fromTo(q(".word-box"), { scale: 0.4, autoAlpha: 0, y: 20 }, { scale: 1, autoAlpha: 1, y: 0, duration: 0.06, ease: "back.out(2)" }, 0.46)
        .fromTo(q(".result"), { yPercent: 120, autoAlpha: 0 }, { yPercent: 0, autoAlpha: 1, duration: 0.06, ease: "power2.out" }, 0.5)
        .to(q(".scan-status, .result, .word-box, .corner"), { autoAlpha: 0, duration: 0.04 }, 0.6)
        .to(q(".phone-screen"), { "--dim": 0, duration: 0.06 }, 0.6)
        .fromTo(q(".panel"), { autoAlpha: 0 }, { autoAlpha: 1, duration: 0.02 }, 0.62)
        .to(q(".phone"), { autoAlpha: 0, duration: 0.02 }, 0.63)
        .fromTo(
          q(".panel"),
          { width: () => phone.offsetWidth, height: () => phone.offsetHeight, borderRadius: 46 },
          { width: () => Math.min(innerWidth * 0.92, 1100), height: () => Math.min(innerHeight * 0.8, wide ? 620 : 760), borderRadius: 36, duration: 0.14, ease: "power2.inOut" },
          0.63,
        )
        .fromTo(q(".panel-item"), { y: 30, autoAlpha: 0 }, { y: 0, autoAlpha: 1, duration: 0.06, stagger: 0.015, ease: "power2.out" }, 0.76);

      if (reduced) tl.progress(1);
    }, root);

    const play = () => intro?.play();
    if ((window as Window & { luminReady?: boolean }).luminReady) play();
    else addEventListener("lumin:ready", play, { once: true });

    return () => {
      removeEventListener("lumin:ready", play);
      ctx.revert();
      scene.dispose();
    };
  }, []);

  return (
    <section ref={root} id="inicio" className="relative h-[560vh] motion-reduce:h-auto" aria-label="Lumin">
      <div className="sticky top-0 h-svh overflow-hidden [perspective:1200px]">
        <canvas ref={canvas} className="absolute inset-0 h-full w-full" aria-hidden />

        <div className="intro absolute inset-x-0 top-0 mx-auto flex h-full max-w-6xl flex-col justify-start px-6 pt-28 md:justify-center md:pt-0">
          <h1 className="max-w-[16ch] font-display text-[clamp(1.85rem,5.4vw,4.4rem)] font-extrabold leading-[1.02] tracking-tight">
            {halves(t.title).map((row) => (
              <span key={row} className="block overflow-hidden pb-1">
                <span className="intro-line inline-block">{row}</span>
              </span>
            ))}
          </h1>
          <p className="intro-fade mt-6 max-w-md text-lg leading-relaxed text-haze">{t.text}</p>
          <div className="intro-fade mt-8 flex flex-wrap items-center gap-3">
            <a href={links.apk} className="inline-flex items-center gap-2 rounded-full bg-mist px-6 py-3.5 font-semibold text-night transition-transform hover:scale-[1.04]">
              <Download size={18} aria-hidden />
              {t.cta}
            </a>
            <a href="#como-funciona" className="group inline-flex items-center gap-2 rounded-full px-5 py-3.5 font-semibold text-mist/90 hover:text-mist">
              {t.secondary}
              <ArrowRight size={16} aria-hidden className="transition-transform group-hover:translate-x-1" />
            </a>
          </div>
          <p className="intro-fade mt-14 flex items-center gap-2 text-sm text-haze">
            <ArrowDown size={16} aria-hidden className="animate-bounce" />
            {t.scroll}
          </p>
        </div>

        <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
          <div className="phone relative aspect-[9/19] w-[min(72vw,300px,40svh)] rounded-[46px] border-[11px] border-[#1d1230] ring-1 ring-white/15 shadow-[0_40px_140px_-20px_rgba(106,0,244,0.7)]">
            <div className="phone-screen absolute inset-0 overflow-hidden rounded-[35px]">
              <div className="absolute left-1/2 top-2 z-10 h-5 w-24 -translate-x-1/2 rounded-full bg-[#1d1230]" />
              <p className="scan-status absolute inset-x-0 top-10 text-center text-xs font-semibold text-scan">{t.ready}</p>
              {[
                "left-[12%] top-[30%] border-l-4 border-t-4 rounded-tl-xl",
                "right-[12%] top-[30%] border-r-4 border-t-4 rounded-tr-xl",
                "left-[12%] bottom-[34%] border-l-4 border-b-4 rounded-bl-xl",
                "right-[12%] bottom-[34%] border-r-4 border-b-4 rounded-br-xl",
              ].map((c) => (
                <span key={c} className={`corner absolute h-9 w-9 border-scan ${c}`} />
              ))}
              <span className="scan-line absolute inset-x-[12%] h-0.5 bg-scan" />
              <div className="word-box absolute left-[8%] right-[8%] top-[18%] flex items-center justify-center gap-2 whitespace-nowrap rounded-2xl border border-scan/60 bg-night px-3 py-2 text-sm font-semibold">
                <Image src={`/flags/${native.flag}.png`} alt="" width={20} height={14} className="h-[14px] w-[20px] object-cover rounded-[3px]" />
                {native.word}
                <ArrowRight size={14} aria-hidden className="text-scan" />
                <Image src={`/flags/${target.flag}.png`} alt="" width={20} height={14} className="h-[14px] w-[20px] object-cover rounded-[3px]" />
                <span className="text-scan">{target.word}</span>
              </div>
              <div className="result absolute inset-x-3 bottom-4 rounded-2xl border border-violet bg-night p-4">
                <p className="text-[10px] font-semibold text-violet">{t.detected}</p>
                <p className="mt-2 text-xs tracking-widest text-mist/60">{native.word.toUpperCase()}</p>
                <p className="font-display text-3xl font-extrabold">{target.word}</p>
              </div>
            </div>
          </div>
        </div>

        <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
          <article className="panel pointer-events-auto relative grid overflow-hidden border-[3px] border-violet/70 bg-night/85 md:bg-night/40 md:grid-cols-2">
            <div className="hidden md:block" aria-hidden />
            <div className="flex flex-col justify-end gap-4 overflow-y-auto p-6 md:justify-center md:p-10">
              <p className="panel-item flex items-center gap-2 text-sm text-haze">
                <Image src={`/flags/${native.flag}.png`} alt="" width={22} height={15} className="h-[15px] w-[22px] object-cover rounded-[3px]" />
                {native.word}
                <ArrowRight size={14} aria-hidden className="text-scan" />
                <Image src={`/flags/${target.flag}.png`} alt="" width={22} height={15} className="h-[15px] w-[22px] object-cover rounded-[3px]" />
                {t.detected}
              </p>
              <div className="panel-item flex flex-wrap items-end gap-4">
                <h2 className="font-display text-[clamp(3rem,7vw,5rem)] font-extrabold leading-none">{target.word}</h2>
                <button
                  type="button"
                  onClick={() => speak(target.word, target.voice)}
                  className="mb-2 inline-flex items-center gap-2 rounded-full border border-scan/60 px-4 py-2 text-sm font-semibold text-scan transition-colors hover:bg-scan hover:text-night"
                >
                  <Volume2 size={16} aria-hidden />
                  {t.listen}
                </button>
              </div>
              <p className="panel-item -mt-2 text-haze">{target.phonetic}</p>
              <div className="panel-item">
                <p className="text-xs font-semibold text-haze">{t.meaningLabel}</p>
                <p className="mt-1 leading-relaxed">{t.meaning}</p>
              </div>
              <div className="panel-item flex flex-wrap items-center gap-2 text-sm">
                <span className="text-xs font-semibold text-haze">{t.categoryLabel}</span>
                <span className="rounded-full bg-violet px-3 py-1 font-semibold">{t.category}</span>
              </div>
              <div className="panel-item rounded-2xl bg-white/5 p-4">
                <p className="text-xs font-semibold text-haze">{t.exampleLabel}</p>
                <div className="mt-1 flex items-start justify-between gap-3">
                  <p className="text-magenta">{t.example}</p>
                  <button type="button" onClick={() => speak(t.example, exampleVoice)} aria-label={t.listen} className="shrink-0 text-scan hover:text-mist">
                    <Volume2 size={18} aria-hidden />
                  </button>
                </div>
                <p className="text-sm text-haze">{t.exampleTranslation}</p>
              </div>
              <div className="panel-item">
                <a href={links.apk} className="inline-flex items-center gap-2 rounded-full bg-mist px-6 py-3 font-semibold text-night transition-transform hover:scale-[1.04]">
                  <Download size={18} aria-hidden />
                  {t.save}
                </a>
                <p className="mt-2 text-xs text-haze">{t.practice}</p>
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>
  );
}

/** Divide o título em duas linhas equilibradas para a revelação da abertura. */
function halves(title: string) {
  const words = title.split(" ");
  const middle = Math.ceil(words.length / 2);
  return [words.slice(0, middle).join(" "), words.slice(middle).join(" ")];
}
