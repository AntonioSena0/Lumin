# Lumin

## Aplicativo de aprendizado de idiomas com tradução em tempo real de objetos do mundo real.

---

## Sobre o Projeto

O **Lumin** é um aplicativo de aprendizado de idiomas que transforma o dia a dia em uma sala de aula.

Com a câmera do celular, o app identifica objetos do mundo real em tempo real e mostra a tradução correspondente, conectando o que o usuário vê ao vocabulário de outro idioma.

O objetivo é ajudar pessoas a aprender vocabulário de forma natural, usando o contexto visual do cotidiano, sem depender apenas de listas de palavras.

---

> Status: Em desenvolvimento (MVP).

---

## Stack Principal

#### Languages and Frameworks:

![Dart](https://img.shields.io/badge/Dart-0175C2.svg?logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B.svg?logo=flutter&logoColor=white)
![Java](https://img.shields.io/badge/Java-%23ED8B00.svg?logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-%236DB33F.svg?logo=springboot&logoColor=white)

#### Database:

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?logo=postgresql&logoColor=white)

#### Tools:

![Docker](https://img.shields.io/badge/Docker-%232496ED.svg?logo=docker&logoColor=white)
![Git](https://img.shields.io/badge/Git-%23F05033.svg?logo=git&logoColor=white)

---

## Funcionalidades

### Funcional nesta versão

- Câmera com detecção de objetos em tempo real
- Identificação do objeto centralizado na tela
- Tradução local do objeto detectado
- Filtro para evitar múltiplas traduções ao mesmo tempo

---

## Como rodar

### API

Crie um arquivo `.env` dentro da pasta `api` baseado no `.env.example`.

Depois, na raiz do projeto, execute:

```bash
docker compose up --build
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

Rode o app no celular ou emulador:

```bash
flutter run
```

Para gerar um APK debug:

```bash
flutter build apk --debug
```

O APK será gerado em:

```bash
mobile/build/app/outputs/flutter-apk/app-debug.apk
```

Para instalar manualmente no celular via ADB:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## Observações do Mobile

- A feature da câmera depende de permissão de câmera no Android.
- O app detecta apenas um objeto por vez, priorizando o objeto centralizado na tela.
- O build pode exibir um aviso sobre Kotlin Gradle Plugin no plugin `ultralytics_yolo`; esse aviso não bloqueia o build atual.

---

## Equipe de Desenvolvedores

- Antonio Sena - https://github.com/AntonioSena0
- Arthur Gutemberg - https://github.com/ArthurGutemberg9
- Beatriz Galdino - https://github.com/Beatriz1505
- Giovanna Torres - https://github.com/GiT0rres

---

© 2026 Lumin. Todos os direitos reservados.
