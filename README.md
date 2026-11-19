# Lumin

## Aplicativo de aprendizado de idiomas com tradução em tempo real de objetos do mundo real.

---

## Sobre o Projeto

O **Lumin** é um aplicativo de aprendizado de idiomas que transforma o dia a dia em uma sala de aula.

Com a câmera do celular, o app identifica objetos do mundo real em tempo real e mostra a tradução correspondente, conectando o que o usuário vê ao vocabulário de outro idioma.

O objetivo é ajudar pessoas a aprender vocabulário de forma natural, usando o contexto visual do cotidiano, sem depender apenas de listas de palavras.

---

> Status: MVP.

---

## Stack Principal

#### Languages and Frameworks:

![Dart](https://img.shields.io/badge/Dart-0175C2.svg?logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B.svg?logo=flutter&logoColor=white)
![Java](https://img.shields.io/badge/Java-%23ED8B00.svg?logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-%236DB33F.svg?logo=springboot&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-000000.svg?logo=nextdotjs&logoColor=white)

#### Database:

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?logo=postgresql&logoColor=white)

#### Tools:

![Docker](https://img.shields.io/badge/Docker-%232496ED.svg?logo=docker&logoColor=white)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-%23FF6600.svg?logo=rabbitmq&logoColor=white)
![Git](https://img.shields.io/badge/Git-%23F05033.svg?logo=git&logoColor=white)

---

## Funcionalidades

### Funcional nesta versão

- Câmera com detecção de objetos em tempo real, no próprio aparelho (439 objetos)
- Identificação do objeto centralizado na tela, com votação entre frames para evitar traduções trocadas
- Tradução local do objeto detectado entre português e inglês
- Salvar palavra com a foto do objeto e validação automática da categoria por IA
- Pesquisa de palavras salvas por outros usuários (catálogo da comunidade), com filtro por categoria
- Sessões de estudo geradas por IA com exercícios de lacuna, tradução, múltipla escolha, reescrita e fala
- Teste de nivelamento
- Perfil público, seguir usuários e listas de seguidores e seguindo
- Interface em português e inglês, com idioma padrão definido pelo IP e alterável nas configurações

---

## Como rodar

### API e serviço de e-mail

Crie um arquivo `.env` dentro das pastas `api` e `mailservice`, baseados nos respectivos `.env.example`.

Depois, na raiz do projeto, execute:

```bash
docker compose up --build
```

A API sobe em `http://localhost:8080` e a documentação Swagger fica em:

```bash
http://localhost:8080/swagger-ui/index.html
```

O RabbitMQ local usa usuário e senha `lumin`. Use esses valores em `RABBIT_USER` e `RABBIT_PASSWORD` nos dois `.env`.

Para rodar os testes da API (sobe um PostgreSQL de teste na porta 5433):

```bash
docker compose --profile test up --build --abort-on-container-exit backend-test
```

---

### Mobile

Pré-requisitos:

- Flutter instalado
- Android Studio instalado
- Android SDK configurado
- Celular Android com depuração USB ativada ou emulador Android aberto

Entre na pasta do app:

```bash
cd mobile
```

Instale as dependências:

```bash
flutter pub get
```

Confira se o dispositivo foi reconhecido:

```bash
flutter devices
```

Rode o app no celular ou emulador (por padrão ele usa a API publicada em `https://lumin.up.railway.app`):

```bash
flutter run
```

Para apontar para a API local, informe a URL na execução (no emulador Android, `10.0.2.2` é o computador):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Para rodar os testes:

```bash
flutter test
```

Para gerar um APK de release:

```bash
flutter build apk --release
```

O APK será gerado em:

```bash
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Para instalar manualmente no celular via ADB:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

### Site

O site de divulgação e download do APK fica na pasta `site`:

```bash
cd site
npm install
npm run dev
```

Na Vercel, importe o repositório e defina `site` como Root Directory.

---

## Observações do Mobile

- A feature da câmera depende de permissão de câmera no Android.
- O app detecta apenas um objeto por vez, priorizando o objeto centralizado na tela.
- Para incluir novos objetos na detecção, adicione uma linha `label,tradução` em `mobile/assets/models/lumin_object_vocabulary.csv` e rode `python tools/export_lumin_yoloe.py` dentro de `mobile` (requer o pacote `ultralytics`).
- O build pode exibir um aviso sobre Kotlin Gradle Plugin no plugin `ultralytics_yolo`; esse aviso não bloqueia o build atual.

---

## Diagramas

Os diagramas de caso de uso e de classe ficam em `docs/diagrams`. Os arquivos `.puml` são a fonte editável e os `.png` são gerados a partir deles com o PlantUML.

---

## Equipe de Desenvolvedores

- Antonio Sena - https://github.com/AntonioSena0
- Arthur Gutemberg - https://github.com/ArthurGutemberg9
- Beatriz Galdino - https://github.com/Beatriz1505
- Giovanna Torres - https://github.com/GiT0rres

---

© 2026 Lumin. Todos os direitos reservados.
