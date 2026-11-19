export const langs = ["pt", "en"] as const;
export type Lang = (typeof langs)[number];

export const links = {
  apk: "https://github.com/AntonioSena0/Lumin/releases/latest/download/lumin.apk",
  repo: "https://github.com/AntonioSena0/Lumin",
};

export const team = [
  { name: "Antonio Sena", github: "AntonioSena0", linkedin: "https://www.linkedin.com/in/antonio-sena-neto", photo: "/team/antonio.webp", role: { pt: "Diagramação e desenvolvimento back-end", en: "Diagrams and back-end development" } },
  { name: "Arthur Gutemberg", github: "ArthurGutemberg9", linkedin: "https://www.linkedin.com/in/arthur-g-83247b3b2", photo: "/team/arthur.webp", role: { pt: "Elaboração do artigo científico", en: "Scientific paper" } },
  { name: "Beatriz Galdino", github: "Beatriz1505", linkedin: "https://www.linkedin.com/in/beatriz-galdino-torres-1b7024307", photo: "/team/beatriz.webp", role: { pt: "Branding e desenvolvimento mobile", en: "Branding and mobile development" } },
  { name: "Giovanna Torres", github: "GiT0rres", linkedin: "https://www.linkedin.com/in/giovanna--torres", photo: "/team/giovanna.webp", role: { pt: "Desenvolvimento mobile e front-end", en: "Mobile and front-end development" } },
];

export const wordPairs = [
  ["Maçã", "Apple"], ["Cadeira", "Chair"], ["Livro", "Book"], ["Violão", "Acoustic guitar"],
  ["Guarda-chuva", "Umbrella"], ["Mochila", "Backpack"], ["Bicicleta", "Bicycle"], ["Fones de ouvido", "Headphones"],
  ["Relógio", "Clock"], ["Luminária", "Lamp"], ["Tesoura", "Scissors"], ["Óculos de sol", "Sunglasses"],
  ["Teclado", "Keyboard"], ["Garrafa", "Bottle"], ["Gato", "Cat"], ["Urso de pelúcia", "Teddy bear"],
] as const;

const pt = {
  meta: {
    title: "Lumin | Aprenda inglês e português com a câmera do celular",
    description:
      "Aponte a câmera para um objeto e o Lumin mostra o nome dele em inglês ou em português. Depois, cada palavra vira exercício. Baixe grátis para Android.",
  },
  nav: { how: "Como funciona", exercises: "Exercícios", screens: "Telas", team: "Equipe", faq: "Dúvidas", cta: "Baixar o app", lang: "Idioma do site" },
  hero: {
    title: "Traduza o mundo com a sua câmera.",
    text: "Aponte o celular para um objeto e o Lumin mostra o nome dele em inglês ou em português, na hora. Depois, cada palavra vira exercício.",
    cta: "Baixar para Android",
    secondary: "Ver como funciona",
    scroll: "Role a página",
    detected: "Objeto detectado",
    ready: "Tradução pronta",
    meaning: "Recipiente com alça, usado para beber café, chá e outras bebidas quentes.",
    listen: "Ouvir pronúncia",
    categoryLabel: "Categoria",
    category: "Objetos Domésticos",
    meaningLabel: "Significado",
    exampleLabel: "Exemplo",
    example: "I drink coffee from my favorite mug.",
    exampleTranslation: "Eu bebo café na minha caneca favorita.",
    save: "Salvar e praticar no app",
    practice: "Ao salvar, o Lumin cria uma sessão de exercícios com esta palavra.",
  },
  globe: {
    title: "439 objetos do dia a dia, reconhecidos sem internet.",
    text: "O reconhecimento roda no próprio celular. Da caneca na mesa ao violão no quarto, o Lumin identifica o objeto no centro da câmera e mostra a tradução.",
    hint: "Alguns dos objetos que o app reconhece",
  },
  steps: {
    title: "Do objeto à palavra que fica na memória.",
    items: [
      { title: "Aponte a câmera", text: "Centralize um objeto. Quando ele fica estável na tela, a tradução aparece com a bandeira de cada idioma." },
      { title: "Salve com a foto", text: "A foto do objeto vira o cartão da palavra. Escolha a categoria e o Lumin confere se ela faz sentido antes de salvar." },
      { title: "Entenda a palavra", text: "Veja a pronúncia, ouça a palavra, leia o significado e exemplos de uso em frases." },
    ],
  },
  exercises: {
    title: "Exercícios que mudam a cada palavra.",
    text: "Cada palavra salva gera uma sessão com 15 exercícios ajustados ao seu nível, misturando escrita e fala.",
    demoLabel: "Monte a tradução",
    demoPrompt: "O teclado está na mesa.",
    demoBlocks: ["The", "keyboard", "is", "on", "the", "desk"],
    demoDistractors: ["mouse", "under"],
    correct: "Correto!",
    types: [
      ["Complete a frase", "Escolha a palavra que fecha a lacuna."],
      ["Monte a tradução", "Toque nos blocos na ordem certa."],
      ["Escolha a resposta", "Qual objeto resolve a situação?"],
      ["Reescreva a frase", "Troque a descrição pela palavra estudada."],
      ["Fale a frase", "Leia em voz alta e o app confere a pronúncia."],
    ],
    levelTitle: "Comece no nível certo",
    levelText: "O teste de nivelamento avalia gramática, leitura e escuta em cerca de 5 minutos.",
  },
  screens: {
    title: "Conheça o app por dentro.",
    text: "Arraste ou role para girar.",
    items: [
      ["/screens/splash.webp", "Boas-vindas"], ["/screens/home.webp", "Início"], ["/screens/camera-hero.webp", "Câmera"],
      ["/screens/salvar.webp", "Salvar tradução"], ["/screens/detalhes.webp", "Detalhes da palavra"], ["/screens/explorar.webp", "Explorar"],
      ["/screens/historico.webp", "Histórico"], ["/screens/nivelamento.webp", "Nivelamento"], ["/screens/perfil.webp", "Perfil"],
      ["/screens/configuracoes.webp", "Configurações"], ["/screens/login.webp", "Login"], ["/screens/cadastro.webp", "Cadastro"],
    ],
  },
  community: {
    title: "Aprenda junto com outras pessoas.",
    items: [
      { title: "Palavras da comunidade", text: "Pesquise palavras que outras pessoas já salvaram, filtre por categoria e adicione à sua lista." },
      { title: "Perfis e seguidores", text: "Encontre amigos pelo nome, veja o perfil de cada um e siga quem estuda com você." },
      { title: "Seu histórico", text: "Tudo o que você traduziu fica guardado para revisar quando quiser." },
    ],
    demo: { search: "teclado", all: "Todas", category: "Tecnologia", results: [["teclado", "keyboard"], ["mouse", "mouse"], ["monitor", "monitor"]], name: "Ana", level: "Nível N2", follow: "Seguir", followers: "Seguidores", history: "Histórico" },
  },
  bilingual: {
    title: "O app fala a sua língua.",
    text: "A interface abre em português ou em inglês de acordo com a sua região, e você troca nas configurações quando quiser. Dá para estudar inglês falando português, ou o contrário.",
  },
  download: {
    title: "Instale em menos de um minuto.",
    text: "O Lumin está em fase de MVP e, por enquanto, é distribuído como arquivo de instalação (APK) para Android.",
    steps: [
      "Toque em Baixar o app. O download começa na hora.",
      "Abra o arquivo lumin.apk pela notificação ou pela pasta Downloads.",
      "Se o Android pedir, permita instalar apps desta fonte e toque em Instalar.",
    ],
    cta: "Baixar o app (APK)",
    qr: "Está no computador? Aponte a câmera do celular para o código e o download começa no aparelho.",
    note: "Disponível apenas para Android.",
  },
  team: { title: "Quem faz o Lumin", text: "Projeto de TCC desenvolvido por quatro estudantes." },
  faq: {
    title: "Dúvidas frequentes",
    items: [
      ["Funciona no iPhone?", "Ainda não. Nesta fase o Lumin está disponível apenas para Android."],
      ["Por que o celular diz que o app é de fonte desconhecida?", "Porque o Lumin é instalado fora da Play Store. É um aviso padrão do Android para qualquer APK. Você pode permitir a instalação só para este arquivo."],
      ["Preciso de internet?", "Para reconhecer objetos, não. Para criar conta, salvar palavras e gerar exercícios, sim."],
      ["Quais idiomas posso estudar?", "Inglês e português, nos dois sentidos."],
      ["O Lumin guarda minhas fotos?", "Não. A foto do objeto aparece só na tela de salvar e não é enviada para o servidor."],
      ["Posso salvar palavras de outras pessoas?", "Sim. Na aba Explorar, pesquise uma palavra, filtre por categoria e salve na sua lista."],
    ],
  },
  footer: { rights: "© 2026 Lumin. Projeto de TCC.", code: "Código no GitHub" },
};

const en: typeof pt = {
  meta: {
    title: "Lumin | Learn English and Portuguese with your phone camera",
    description:
      "Point your camera at an object and Lumin shows its name in English or Portuguese. Then every word becomes practice. Free download for Android.",
  },
  nav: { how: "How it works", exercises: "Exercises", screens: "Screens", team: "Team", faq: "FAQ", cta: "Get the app", lang: "Site language" },
  hero: {
    title: "Translate the world with your camera.",
    text: "Point your phone at an object and Lumin shows its name in English or Portuguese, right away. Then every word becomes practice.",
    cta: "Download for Android",
    secondary: "See how it works",
    scroll: "Scroll down",
    detected: "Object detected",
    ready: "Translation ready",
    meaning: "A cup with a handle, used for drinking coffee, tea and other hot drinks.",
    listen: "Listen",
    categoryLabel: "Category",
    category: "Household Items",
    meaningLabel: "Meaning",
    exampleLabel: "Example",
    example: "Eu bebo café na minha caneca favorita.",
    exampleTranslation: "I drink coffee from my favorite mug.",
    save: "Save and practice in the app",
    practice: "When you save it, Lumin creates an exercise session with this word.",
  },
  globe: {
    title: "439 everyday objects, recognized offline.",
    text: "Recognition runs on the phone itself. From the mug on your desk to the guitar in your room, Lumin identifies the object in the center of the camera and shows the translation.",
    hint: "Some of the objects the app recognizes",
  },
  steps: {
    title: "From the object to a word you remember.",
    items: [
      { title: "Point the camera", text: "Center an object. Once it is steady on screen, the translation appears with each language's flag." },
      { title: "Save it with the photo", text: "The photo of the object becomes the word's card. Pick a category and Lumin checks that it makes sense before saving." },
      { title: "Understand the word", text: "See the pronunciation, listen to the word, read its meaning and example sentences." },
    ],
  },
  exercises: {
    title: "Exercises that change with every word.",
    text: "Every saved word creates a session with 15 exercises tuned to your level, mixing writing and speaking.",
    demoLabel: "Build the translation",
    demoPrompt: "O teclado está na mesa.",
    demoBlocks: ["The", "keyboard", "is", "on", "the", "desk"],
    demoDistractors: ["mouse", "under"],
    correct: "Correct!",
    types: [
      ["Complete the sentence", "Pick the word that fills the gap."],
      ["Build the translation", "Tap the blocks in the right order."],
      ["Choose the answer", "Which object solves the situation?"],
      ["Rewrite the sentence", "Swap the description for the word you are learning."],
      ["Say the sentence", "Read it out loud and the app checks it."],
    ],
    levelTitle: "Start at the right level",
    levelText: "The placement test checks grammar, reading and listening in about 5 minutes.",
  },
  screens: {
    title: "Take a look inside the app.",
    text: "Drag or scroll to spin.",
    items: [
      ["/screens/splash.webp", "Welcome"], ["/screens/home.webp", "Home"], ["/screens/camera-hero.webp", "Camera"],
      ["/screens/salvar.webp", "Save translation"], ["/screens/detalhes.webp", "Word details"], ["/screens/explorar.webp", "Explore"],
      ["/screens/historico.webp", "History"], ["/screens/nivelamento.webp", "Placement test"], ["/screens/perfil.webp", "Profile"],
      ["/screens/configuracoes.webp", "Settings"], ["/screens/login.webp", "Login"], ["/screens/cadastro.webp", "Sign up"],
    ],
  },
  community: {
    title: "Learn together with other people.",
    items: [
      { title: "Community words", text: "Search words other people have already saved, filter by category and add them to your list." },
      { title: "Profiles and followers", text: "Find friends by name, check their profiles and follow the people who study with you." },
      { title: "Your history", text: "Everything you translate is kept so you can review it whenever you want." },
    ],
    demo: { search: "keyboard", all: "All", category: "Technology", results: [["keyboard", "teclado"], ["mouse", "mouse"], ["monitor", "monitor"]], name: "Ana", level: "Level N2", follow: "Follow", followers: "Followers", history: "History" },
  },
  bilingual: {
    title: "The app speaks your language.",
    text: "The interface opens in English or Portuguese based on your region, and you can switch it in settings anytime. Learn English from Portuguese, or the other way around.",
  },
  download: {
    title: "Install it in under a minute.",
    text: "Lumin is an MVP and, for now, it is distributed as an installation file (APK) for Android.",
    steps: [
      "Tap Get the app. The download starts right away.",
      "Open lumin.apk from the notification or your Downloads folder.",
      "If Android asks, allow installs from this source and tap Install.",
    ],
    cta: "Get the app (APK)",
    qr: "On a computer? Point your phone camera at the code and the download starts on the phone.",
    note: "Android only.",
  },
  team: { title: "The people behind Lumin", text: "A final-year project built by four students." },
  faq: {
    title: "Frequently asked questions",
    items: [
      ["Does it work on iPhone?", "Not yet. For now Lumin is available for Android only."],
      ["Why does my phone say the app comes from an unknown source?", "Because Lumin is installed outside the Play Store. Android shows this warning for every APK. You can allow it just for this file."],
      ["Do I need internet?", "Not to recognize objects. You do need it to create an account, save words and generate exercises."],
      ["Which languages can I learn?", "English and Portuguese, both ways."],
      ["Does Lumin keep my photos?", "No. The photo of the object only shows up on the save screen and is never sent to the server."],
      ["Can I save words from other people?", "Yes. In the Explore tab, search for a word, filter by category and save it to your list."],
    ],
  },
  footer: { rights: "© 2026 Lumin. A final-year project.", code: "Code on GitHub" },
};

export const dict = { pt, en };
export type Dict = typeof pt;
