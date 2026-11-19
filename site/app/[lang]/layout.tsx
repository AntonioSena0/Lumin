import type { Metadata, Viewport } from "next";
import { Bricolage_Grotesque, Poppins } from "next/font/google";
import Cursor from "@/components/Cursor";
import Loader from "@/components/Loader";
import SmoothScroll from "@/components/SmoothScroll";
import SpaceBackground from "@/components/SpaceBackground";
import { dict, langs, type Lang } from "@/lib/content";
import "../globals.css";

const bricolage = Bricolage_Grotesque({ variable: "--font-bricolage", subsets: ["latin"], weight: ["700", "800"] });
const poppins = Poppins({ variable: "--font-poppins", subsets: ["latin"], weight: ["400", "500", "600"] });

const siteUrl = process.env.VERCEL_PROJECT_PRODUCTION_URL
  ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
  : "http://localhost:3000";

/** Gera as duas versões estáticas do site: /pt e /en. */
export function generateStaticParams() {
  return langs.map((lang) => ({ lang }));
}

/** Metadados de SEO no idioma da página, com links alternativos entre as versões. */
export async function generateMetadata({ params }: LayoutProps<"/[lang]">): Promise<Metadata> {
  const { lang } = await params;
  const t = dict[lang as Lang] ?? dict.pt;
  return {
    metadataBase: new URL(siteUrl),
    title: t.meta.title,
    description: t.meta.description,
    alternates: { canonical: `/${lang}`, languages: { "pt-BR": "/pt", en: "/en" } },
    openGraph: { title: "Lumin", description: t.meta.description, images: ["/brand/logo.png"], locale: lang === "pt" ? "pt_BR" : "en_US", type: "website" },
    icons: { icon: "/brand/logo.png" },
  };
}

export const viewport: Viewport = { themeColor: "#070111" };

/** Estrutura raiz da página no idioma da URL, com fundo espacial e scroll suave. */
export default async function LangLayout({ children, params }: LayoutProps<"/[lang]">) {
  const raw = (await params).lang;
  const lang: Lang = langs.includes(raw as Lang) ? (raw as Lang) : "pt";
  return (
    <html lang={lang === "pt" ? "pt-BR" : "en"} className={`${bricolage.variable} ${poppins.variable} antialiased`}>
      <body>
        <noscript>
          <style>{".loader{display:none}"}</style>
        </noscript>
        <Loader label={lang === "pt" ? "Carregando" : "Loading"} />
        <SpaceBackground />
        <SmoothScroll />
        <Cursor />
        {children}
      </body>
    </html>
  );
}
