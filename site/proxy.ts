import { NextResponse, type NextRequest } from "next/server";

const portugueseCountries = new Set(["BR", "PT", "AO", "MZ", "CV", "GW", "ST", "TL"]);

/** Escolhe o idioma: escolha salva no cookie, depois país do IP (header da Vercel) e por fim o idioma do navegador. */
function pickLang(request: NextRequest): "pt" | "en" {
  const saved = request.cookies.get("lang")?.value;
  if (saved === "pt" || saved === "en") return saved;
  const country = request.headers.get("x-vercel-ip-country");
  if (country) return portugueseCountries.has(country.toUpperCase()) ? "pt" : "en";
  return request.headers.get("accept-language")?.toLowerCase().startsWith("pt") ? "pt" : "en";
}

/** Redireciona a raiz do site para a versão no idioma do visitante. */
export function proxy(request: NextRequest) {
  const url = request.nextUrl.clone();
  url.pathname = `/${pickLang(request)}`;
  return NextResponse.redirect(url);
}

export const config = {
  matcher: ["/"],
};
