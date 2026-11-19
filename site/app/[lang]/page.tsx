import Image from "next/image";
import { notFound } from "next/navigation";
import Bilingual from "@/components/Bilingual";
import Community from "@/components/Community";
import DownloadSection from "@/components/DownloadSection";
import ExerciseDemo from "@/components/ExerciseDemo";
import Faq from "@/components/Faq";
import Globe from "@/components/Globe";
import Header from "@/components/Header";
import Hero from "@/components/Hero";
import ScreensRing from "@/components/ScreensRing";
import Steps from "@/components/Steps";
import Team from "@/components/Team";
import { dict, langs, links, type Lang } from "@/lib/content";

/** Página do site no idioma da URL, na ordem da jornada: descobrir, entender, praticar, baixar. */
export default async function Home({ params }: PageProps<"/[lang]">) {
  const lang = (await params).lang as Lang;
  if (!langs.includes(lang)) notFound();
  const t = dict[lang];

  return (
    <>
      <Header lang={lang} t={t.nav} />
      <main>
        <Hero lang={lang} t={t.hero} />
        <Globe lang={lang} t={t.globe} />
        <Steps t={t.steps} />
        <ExerciseDemo t={t.exercises} />
        <ScreensRing t={t.screens} />
        <Community t={t.community} />
        <Bilingual t={t.bilingual} />
        <DownloadSection t={t.download} />
        <Team lang={lang} t={t.team} />
        <Faq t={t.faq} />
      </main>
      <footer className="mx-auto flex max-w-6xl flex-col gap-4 border-t border-white/10 px-6 py-10 text-sm text-haze md:flex-row md:items-center md:justify-between">
        <span className="flex items-center gap-2">
          <Image src="/brand/logo.png" alt="" width={24} height={24} />
          {t.footer.rights}
        </span>
        <a href={links.repo} target="_blank" rel="noreferrer" className="hover:text-mist">
          {t.footer.code}
        </a>
      </footer>
    </>
  );
}
