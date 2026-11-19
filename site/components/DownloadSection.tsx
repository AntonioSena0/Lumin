import QRCode from "qrcode";
import { Download, Smartphone } from "lucide-react";
import { links, type Dict } from "@/lib/content";

/** Chamada de download direto do APK, com passo a passo para leigos e QR code para baixar pelo celular. */
export default async function DownloadSection({ t }: { t: Dict["download"] }) {
  const qr = await QRCode.toString(links.apk, {
    type: "svg",
    margin: 0,
    errorCorrectionLevel: "M",
    color: { dark: "#070111", light: "#f6f0ff" },
  });

  return (
    <section id="baixar" className="mx-auto max-w-6xl px-6 py-32" aria-labelledby="download-title">
      <div className="glass relative overflow-hidden rounded-[44px] border-violet/50 p-8 md:p-14">
        <div className="relative grid gap-12 md:grid-cols-[1.3fr_1fr]">
          <div>
            <h2 id="download-title" className="font-display text-[clamp(2.2rem,5vw,3.8rem)] font-extrabold leading-[1]">
              {t.title}
            </h2>
            <p className="mt-4 max-w-lg text-mist/85">{t.text}</p>
            <ol className="mt-8 space-y-4">
              {t.steps.map((step, i) => (
                <li key={step} className="flex items-start gap-4">
                  <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-mist font-display font-bold text-night">
                    {i + 1}
                  </span>
                  <span className="pt-1 text-mist/90">{step}</span>
                </li>
              ))}
            </ol>
            <a
              href={links.apk}
              className="mt-10 inline-flex items-center gap-2 rounded-full bg-mist px-8 py-4 text-lg font-semibold text-night shadow-[0_0_50px_rgba(246,240,255,0.35)] transition-transform hover:scale-[1.04]"
            >
              <Download size={22} aria-hidden />
              {t.cta}
            </a>
            <p className="mt-4 flex items-center gap-2 text-sm text-mist/75">
              <Smartphone size={16} aria-hidden />
              {t.note}
            </p>
          </div>
          <div className="hidden flex-col items-center justify-center gap-5 md:flex">
            <div className="rounded-3xl bg-mist p-5 shadow-[0_20px_60px_rgba(7,1,17,0.5)]">
              <div className="h-44 w-44 [&_svg]:h-full [&_svg]:w-full" role="img" aria-label={t.qr} dangerouslySetInnerHTML={{ __html: qr }} />
            </div>
            <p className="max-w-[16rem] text-center text-sm text-mist/85">{t.qr}</p>
          </div>
        </div>
      </div>
    </section>
  );
}
