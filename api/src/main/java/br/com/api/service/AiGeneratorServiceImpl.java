package br.com.api.service;

import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.entity.Word;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.openai.api.ResponseFormat;
import org.springframework.stereotype.Service;


@Service
public class AiGeneratorServiceImpl implements AiGeneratorService{

    private final ChatClient chatClient;

    public AiGeneratorServiceImpl(ChatClient.Builder builder) {
        this.chatClient = builder.build();
    }

    @Override
    public String generateDescription(String original, String translated, String category, String language) {

        String prompt = buildDescriptionPrompt(original, translated, category, language);

        String description = chatClient.prompt()
                .user(prompt)
                .options(ChatOptions.builder()
                        .maxTokens(40)
                        .temperature(0.1)
                        .build())
                .call()
                .content();

        return sanitizeDescription(description);

    }

    private String buildDescriptionPrompt(String original, String translated, String category, String language) {
        return """
        Você é um especialista em linguística.

        Gere uma descrição curta para uma palavra.

        PALAVRA ORIGINAL:
        %s

        TRADUÇÃO:
        %s

        CATEGORIA:
        %s

        IDIOMA DA DESCRIÇÃO:
        %s

        REGRAS:

        - Considere a categoria para desambiguar o significado.
        - Explique apenas o significado principal.
        - Entre 5 e 20 palavras.
        - Sem exemplos.
        - Sem observações.
        - Sem listas.
        - Sem markdown.
        - Sem aspas.
        - Retorne apenas a descrição.

        Exemplo:

        Dispositivo de entrada usado para digitar textos e comandos em computadores.
        """.formatted(
            original,
            translated,
            category,
            language
        );
    }

    private String sanitizeDescription(String description) {

        if (description == null) {
            return "";
        }

        return description
                .replace("\"", "")
                .replace("Descrição:", "")
                .replace("Description:", "")
                .trim();
    }

    @Override
    public StudySessionAiResponse generateStudySession(Word word, String fromLanguage, String toLanguage){

        var conversor = new BeanOutputConverter<>(StudySessionAiResponse.class);

        String prompt = buildStudySessionPrompt(
                word.getOriginal(),
                word.getTranslated(),
                word.getDescription(),
                word.getCategory().getName(),
                fromLanguage,
                toLanguage,
                conversor.getFormat()
        );

        ResponseFormat responseFormat = ResponseFormat.builder()
                .type(ResponseFormat.Type.JSON_OBJECT)
                .build();

        return chatClient.prompt()
                .options(OpenAiChatOptions.builder()
                        .responseFormat(responseFormat)
                        .temperature(0.2)
                        .build()
                )
                .user(prompt)
                .call()
                .entity(StudySessionAiResponse.class);

    }

    private String buildStudySessionPrompt(String original, String translated, String description, String category, String fromLanguage, String toLanguage, String outputFormat) {

        return """
        =================================================
        OBJETIVO DA SESSÃO
        =================================================

        Você é um designer pedagógico especializado em aprendizado de vocabulário por contexto visual.

        Crie uma sessão curta, natural e coesa para um usuário que acabou de identificar um objeto real pela câmera do aplicativo Lumin.

        A sessão deve reforçar a associação entre o objeto visto, a palavra no idioma de estudo e situações reais de uso.

        Evite exercícios genéricos de dicionário. O usuário não deve sentir que está respondendo uma definição escolar.

        =================================================
        DADOS DA PALAVRA
        =================================================

        Palavra no idioma de origem:
        %1$s

        Palavra no idioma de estudo:
        %2$s

        Descrição:
        %3$s

        Categoria:
        %4$s

        Idioma de origem:
        %5$s

        Idioma de estudo:
        %6$s

        Use a descrição e a categoria para decidir o contexto correto.

        Nunca use apenas a tradução isolada para interpretar a palavra.

        Se houver conflito entre tradução, descrição e categoria, priorize a descrição.

        =================================================
        REGRAS DE COESÃO
        =================================================

        Todos os exercícios devem parecer parte de situações reais do cotidiano.

        Crie contextos como:

        - alguém usando o objeto
        - alguém procurando o objeto
        - alguém comprando ou substituindo o objeto
        - alguém organizando um ambiente onde o objeto aparece
        - alguém resolvendo um problema cotidiano relacionado ao objeto

        Não crie perguntas genéricas como:

        - What is the primary function of...
        - What does ... mean?
        - Which word means...
        - Choose the correct translation.
        - Translate the word...
        - What is the correct word for...

        Não use contextos incompatíveis com a categoria.

        Não misture objetos de categorias aleatórias apenas para preencher alternativas.

        Não repita o mesmo cenário em vários exercícios.

        =================================================
        QUANTIDADE OBRIGATÓRIA
        =================================================

        Gere exatamente 15 exercícios:

        - 10 writtenExercises
        - 5 speakingExercises

        Em writtenExercises, gere exatamente:

        - 3 FILL_IN
        - 2 TRANSLATE
        - 3 MULTIPLE_CHOICE
        - 2 REWRITE

        =================================================
        CAMPOS DE writtenExercises
        =================================================

        Cada exercício escrito deve conter exatamente estes campos:

        - title
        - instruction
        - prompt
        - correctAnswer
        - options
        - subType

        subType deve ser um destes valores:

        - FILL_IN
        - TRANSLATE
        - MULTIPLE_CHOICE
        - REWRITE

        =================================================
        FILL_IN
        =================================================

        O prompt deve ser uma frase natural em %6$s com uma lacuna _____.

        A lacuna deve substituir a palavra:
        %2$s

        correctAnswer deve ser exatamente:
        %2$s

        options deve ser [].

        O contexto deve permitir inferir a palavra sem perguntar sua definição.

        Bom exemplo para keyboard:
        "The developer cleaned the _____ before starting work."

        Exemplo ruim:
        "A _____ is used for typing."

        =================================================
        TRANSLATE
        =================================================

        O prompt deve ser uma frase curta, natural e cotidiana em %5$s.

        A frase deve conter a palavra no idioma de origem:
        %1$s

        correctAnswer deve ser uma frase equivalente em %6$s contendo:
        %2$s

        options deve ser [].

        Não peça tradução de palavra solta.

        =================================================
        MULTIPLE_CHOICE
        =================================================

        O prompt deve ser uma situação prática em %6$s.

        A pergunta deve fazer o usuário escolher o objeto ou palavra que melhor resolve aquela situação.

        Nunca faça pergunta de definição.

        options deve conter exatamente 4 itens.

        Uma opção deve ser exatamente:
        %2$s

        As outras 3 opções devem ser plausíveis no mesmo ambiente ou categoria, mas incorretas para a situação.

        correctAnswer deve ser exatamente:
        %2$s

        Bom exemplo para keyboard:
        "The intern needs to type a long report on the office computer. Which item should she use?"

        Exemplo ruim:
        "What is the primary function of a keyboard?"

        =================================================
        REWRITE
        =================================================

        O prompt deve ser uma frase em %6$s que descreva a palavra sem usar:
        %2$s

        correctAnswer deve reescrever a frase usando:
        %2$s

        options deve ser [].

        Bom exemplo para keyboard:
        "The designer replaced the input device used for typing."

        Exemplo ruim:
        "The designer replaced the keyboard."

        =================================================
        CAMPOS DE speakingExercises
        =================================================

        Cada exercício de fala deve conter exatamente estes campos:

        - title
        - instruction
        - prompt
        - requiredWords

        O usuário apenas lê a frase em voz alta.

        Não crie pergunta aberta.

        Não peça opinião.

        Não peça explicação.

        Não peça conversa, roleplay ou descrição livre.

        prompt deve ser uma frase natural em %6$s com 6 a 18 palavras.

        prompt deve conter literalmente:
        %2$s

        requiredWords deve ter entre 3 e 8 palavras importantes presentes no prompt.

        requiredWords deve incluir:
        %2$s

        =================================================
        QUALIDADE DOS TÍTULOS E INSTRUÇÕES
        =================================================

        Os títulos devem ser específicos e diferentes entre si.

        Não use:

        - Exercise 1
        - Exercise 2
        - Fill In
        - Translate
        - Speaking Exercise
        - Choosing the Right Equipment repetidamente

        As instruções devem ser curtas e adequadas ao tipo do exercício.

        Bons títulos para uma palavra de tecnologia:

        - Setting Up the Desk
        - Replacing Office Gear
        - Typing a Secure Password
        - Cleaning the Workstation
        - Preparing a Study Space

        =================================================
        AUTOVERIFICAÇÃO OBRIGATÓRIA
        =================================================

        Antes de responder, valide internamente:

        - Existem exatamente 15 exercícios.
        - Existem exatamente 10 writtenExercises.
        - Existem exatamente 5 speakingExercises.
        - Existem exatamente 3 FILL_IN.
        - Existem exatamente 2 TRANSLATE.
        - Existem exatamente 3 MULTIPLE_CHOICE.
        - Existem exatamente 2 REWRITE.
        - Nenhum MULTIPLE_CHOICE é pergunta de definição.
        - Nenhum exercício pede apenas tradução de palavra solta.
        - Todo FILL_IN usa _____.
        - Todo REWRITE evita a palavra estudada no prompt.
        - Todo speaking prompt contém a palavra estudada.
        - Todo requiredWords contém a palavra estudada.
        - Todo MULTIPLE_CHOICE possui exatamente 4 opções.
        - Todos os títulos são únicos.
        - Todos os prompts são únicos.
        - Todos os contextos respeitam descrição e categoria.

        Se qualquer regra falhar, corrija antes de responder.

        =================================================
        SAÍDA
        =================================================

        Retorne somente JSON válido.

        Não utilize markdown.

        Não utilize explicações.

        Não utilize comentários.

        Não escreva nada antes do JSON.

        Não escreva nada depois do JSON.

        Use exatamente este formato de saída:

        %7$s
        """.formatted(
                original,
                translated,
                description,
                category,
                fromLanguage,
                toLanguage,
                outputFormat
        );
    }

}
