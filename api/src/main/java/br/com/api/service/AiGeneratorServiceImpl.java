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
                .user(prompt + "\n" + conversor.getFormat())
                .call()
                .entity(StudySessionAiResponse.class);

    }

    private String buildStudySessionPrompt(String original, String translated, String description, String category, String fromLanguage, String toLanguage, String outputFormat) {

        return """
        =================================================
        REGRAS CRÍTICAS DE GERAÇÃO
        =================================================
        
        Estas regras possuem prioridade máxima.
        
        Se qualquer regra for violada, você deve corrigir a sessão antes de responder.
        
        Os exercícios não devem apenas solicitar diretamente a palavra-alvo.
        
        Crie situações realistas do cotidiano nas quais compreender o significado da palavra seja necessário para responder corretamente.
        
        Evite repetir a palavra-alvo diretamente no enunciado sempre que possível. Em vez disso, utilize descrições, funções, características, ações ou contextos relacionados ao objeto.
        
        Utilize contextos variados, incluindo diferentes ambientes, profissões, faixas etárias, atividades e situações do dia a dia.
        
        Os exercícios devem estimular a compreensão do vocabulário dentro de um contexto, e não apenas a memorização da tradução.
        
        Para exercícios de speaking, solicite que o usuário produza respostas originais, descreva experiências, explique situações ou fale sobre objetos e cenários relacionados, evitando atividades de simples leitura em voz alta.
        
        Considere que o usuário aprendeu a palavra a partir da observação de um objeto real no ambiente através da câmera do aplicativo. Sempre que possível, conecte os exercícios ao uso prático desse objeto no mundo real.
        
        Mantenha os exercícios naturais, úteis e relevantes para situações que o usuário pode encontrar em casa, na escola, no trabalho, na rua ou em outros ambientes cotidianos.
        
        Ao criar exercícios, assuma que o usuário acabou de identificar visualmente um objeto através da câmera do aplicativo. Utilize características visuais, função, localização comum e interações típicas com esse objeto para construir perguntas que reforcem a associação entre a imagem observada e o vocabulário aprendido.
        
        =================================================
        ENTENDIMENTO DA PALAVRA
        =================================================
        
        PALAVRA ORIGINAL:
        %s
        
        TRADUÇÃO:
        %s
        
        DESCRIÇÃO:
        %s
        
        CATEGORIA:
        %s
        
        Você deve considerar os quatro campos acima simultaneamente.
        
        NUNCA utilize apenas a tradução para interpretar a palavra.
        
        NUNCA crie fatos ireais ou que possuam coisas em comum com outras palavras

        TODOS os cenários precisam ser plausíveis e encontrados na vida real de maneira cotidiana
        
        A descrição é a fonte principal de significado.
        
        A categoria serve para eliminar ambiguidades.
        
        Antes de criar os exercícios:
        
        1. Identifique o significado correto.
        2. Identifique o objeto, conceito ou ação representado.
        3. Identifique contextos reais de uso.
        4. Gere exercícios coerentes com esse significado.
        
        Se existir conflito entre tradução e categoria:
        
        PRIORIZE a descrição.
        
        =================================================
        CONTROLE DE CONTEXTO
        =================================================
        
        Todos os exercícios devem respeitar:
        
        - significado
        - descrição
        - categoria
        
        Exemplo:
        
        PALAVRA:
        Keyboard
        
        DESCRIÇÃO:
        Dispositivo de entrada usado para digitar textos e comandos em computadores.
        
        CATEGORIA:
        Tecnologia
        
        Contextos permitidos:
        
        - computadores
        - programação
        - escritório
        - produtividade
        - hardware
        - setup gamer
        - tecnologia
        - internet
        - digitação
        
        Contextos proibidos:
        
        - culinária
        - agricultura
        - medicina
        - animais
        - esportes sem relação tecnológica
        
        Nunca utilize contextos proibidos.
        
        =================================================
        QUANTIDADE OBRIGATÓRIA
        =================================================
        
        A sessão DEVE possuir exatamente:
        
        10 exercícios escritos
        
        5 exercícios de pronúncia
        
        Total:
        
        15 exercícios
        
        Se o total for diferente de 15:
        
        REFAÇA A GERAÇÃO.
        
        =================================================
        EXERCÍCIOS ESCRITOS
        =================================================
        
        Gerar exatamente:
        
        - 3 FILL_IN
        - 2 TRANSLATE
        - 3 MULTIPLE_CHOICE
        - 2 REWRITE
        
        Total obrigatório:
        
        10 exercícios escritos.
        
        =================================================
        FILL_IN
        =================================================
        
        Regras:
        
        - A palavra estudada deve ser a resposta correta.
        - Substituir por _____.
        - Contexto suficiente para inferência.
        - Frase natural.
        - A frase deve sempre ser em %s, porque a resposta é em %s
        
        Exemplo:
        
        "The developer replaced his _____ before the tournament."
        
        =================================================
        TRANSLATE
        =================================================
        
        IMPORTANTE:
        
        O texto apresentado ao aluno deve estar em:
        
        %s
        
        A resposta esperada deve estar em:
        
        %s
        
        A frase obrigatoriamente deve conter a palavra estudada.
        
        =================================================
        MULTIPLE CHOICE
        =================================================
        
        Obrigatório:
        
        - 4 alternativas
        - 1 correta
        - 3 distratores plausíveis
        
        Distratores devem pertencer ao mesmo domínio semântico.
        
        Exemplo:
        
        keyboard
        mouse
        monitor
        printer
        
        Exemplo proibido:
        
        keyboard
        elephant
        pizza
        mountain
        
        =================================================
        REWRITE
        =================================================
        
        ERRO CRÍTICO A EVITAR
        
        A frase original NÃO pode conter a palavra estudada.
        
        NUNCA.
        
        ERRADO:
        
        "The developer cleaned his keyboard."
        
        CORRETO:
        
        "The developer cleaned his input device."
        
        Objetivo:
        
        O aluno deve reescrever usando a palavra estudada.
        
        =================================================
        EXERCÍCIOS DE PRONÚNCIA
        =================================================
        
        Gerar exatamente:
        
        5 exercícios.
        
        IMPORTANTE:
        
        O aluno NÃO responde perguntas.
        
        O aluno NÃO descreve situações.
        
        O aluno NÃO cria frases.
        
        O aluno NÃO explica nada.
        
        O aluno apenas lê a frase exibida.
        
        Portanto:
        
        Cada exercício deve conter:
        
        title
        phrase
        difficulty
        requiredWords
        
        Não utilizar:
        
        - open questions
        - discussions
        - explanations
        - descriptions
        - roleplay
        
        =================================================
        FRASES DE PRONÚNCIA
        =================================================
        
        Obrigatório:
        
        - entre 6 e 20 palavras
        - linguagem natural
        - contexto real
        - conter a palavra estudada explicitamente
        
        A palavra estudada deve aparecer literalmente na frase.
        
        Exemplo:
        
        "The programmer bought a new keyboard for his home office."
        
        =================================================
        REQUIRED WORDS
        =================================================
        
        Regras obrigatórias:
        
        - entre 3 e 8 palavras
        - deve conter a palavra estudada
        - deve conter palavras relevantes da frase
        - deve permitir validação de leitura
        
        PROIBIDO:
        
        ["keyboard"]
        
        CORRETO:
        
        [
          "programmer",
          "new",
          "keyboard",
          "office"
        ]
        
        =================================================
        QUALIDADE DOS TÍTULOS
        =================================================
        
        Proibido:
        
        - Exercise 1
        - Exercise 2
        - Fill In
        - Translate
        - Speaking Exercise
        
        Obrigatório:
        
        Títulos específicos e contextuais.
        
        Exemplos:
        
        - Upgrading the Workstation
        - Preparing for the Hackathon
        - Choosing Office Equipment
        - Remote Team Setup
        
        =================================================
        PROGRESSÃO DE DIFICULDADE
        =================================================
        
        Distribuição obrigatória:
        
        Exercícios 1-5:
        EASY
        
        Exercícios 6-10:
        MEDIUM
        
        Exercícios 11-15:
        HARD
        
        =================================================
        AUTOVERIFICAÇÃO OBRIGATÓRIA
        =================================================
        
        Antes de responder valide:
        
        ✓ 15 exercícios
        
        ✓ 10 escritos
        
        ✓ 5 pronúncia
        
        ✓ 3 FILL_IN
        
        ✓ 2 TRANSLATE
        
        ✓ 3 MULTIPLE_CHOICE
        
        ✓ 2 REWRITE
        
        ✓ Nenhum REWRITE contém a palavra estudada
        
        ✓ Nenhum speaking é pergunta aberta
        
        ✓ Todas as frases de speaking contêm a palavra estudada
        
        ✓ Todos requiredWords possuem entre 3 e 8 palavras
        
        ✓ Todos requiredWords contêm a palavra estudada
        
        ✓ Todos os títulos são únicos
        
        ✓ Todas as frases são únicas
        
        ✓ Categoria respeitada
        
        ✓ Descrição respeitada
        
        ✓ Contextos coerentes
        
        Se qualquer item falhar:
        
        CORRIJA ANTES DE RESPONDER.
        
        =================================================
        SAÍDA
        =================================================
        
        Retorne SOMENTE JSON válido.
        
        Não utilize markdown.
        
        Não utilize explicações.
        
        Não utilize comentários.
        
        Não escreva nada antes do JSON.
        
        Não escreva nada depois do JSON.
                
        TODOS os campos precisam estar fechados por aspas duplas
        
        Example:
        {
          "writtenExercises": [],
          "speakingExercises": []
        }
        
        %s
        """.formatted(
                original,
                translated,
                description,
                category,
                toLanguage,
                toLanguage,
                fromLanguage,
                toLanguage,
                outputFormat
        );
    }

}
