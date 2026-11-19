# Lumin - Site

Landing page do Lumin, com download do APK para Android.

Next.js 16 (App Router), Tailwind CSS 4, GSAP + ScrollTrigger, Lenis e three.js.

## Como rodar

```bash
cd site
npm install
npm run dev
```

Acesse `http://localhost:3000`.

## Deploy na Vercel

1. Importe o repositório `AntonioSena0/Lumin` na Vercel.
2. Em **Root Directory**, selecione `site`.
3. Mantenha o framework detectado (Next.js) e faça o deploy.

## Download do APK

O botão "Baixar APK" aponta para a última release do repositório (`lib/content.ts`, campo `links.apk`). Para publicar uma nova versão, gere o APK em `mobile/` e anexe o arquivo a uma release no GitHub.
