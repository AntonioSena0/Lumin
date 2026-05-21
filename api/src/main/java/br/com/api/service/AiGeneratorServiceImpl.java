package br.com.api.service;

import br.com.api.domain.WrittenType;
import br.com.api.dto.response.WrittenExerciseAiResponse;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.stereotype.Service;

@Service
public class AiGeneratorServiceImpl implements AiGeneratorService{

    private final ChatClient chatClient;

    public AiGeneratorServiceImpl(ChatClient.Builder builder) {
        this.chatClient = builder.build();
    }

    public WrittenExerciseAiResponse generateWrittenExercise(String word, String from_language, String to_language){

        WrittenType type = randomExerciseType();

        var conversor = new BeanOutputConverter<>(WrittenExerciseAiResponse.class);

        String prompt = switch (type) {
            case FILL_IN -> """
                    Crie um exercício de "preencher lacuna" em %s para a palavra '%s'.
                    Use uma frase em %s com a palavra em %s em um espaço em branco.
                    Retorne apenas o JSON no formato: %s
                    """.formatted(from_language, word, to_language, to_language, conversor.getFormat());

            case TRANSLATE -> """
                    Crie um exercício de "tradução" em %s para a palavra '%s'.
                    Dê uma frase em %s contendo a palavra '%s' em %s e peça para o usuário traduzir para %s.
                    Retorne apenas o JSON no formato: %s
                    """.formatted(from_language, word, to_language, word, to_language, from_language, conversor.getFormat());

            case MULTIPLE_CHOICE -> """
                    Crie um exercício de "múltipla escolha" em %s para a palavra '%s' e as escolhas em %s.
                    Forneça 4 opções, com exatamente uma correta, e indique qual é.
                    Retorne apenas o JSON no formato: %s
                    """.formatted(from_language, word, to_language, conversor.getFormat());

            case REWRITE -> """
                    Crie um exercício de "reescrever frase" em %s para a palavra '%s' (traduza a palavra também).
                    Dê uma frase em que o usuário deve reescrevê‑la usando essa palavra de forma adequada.
                    Retorne apenas o JSON no formato: %s
                    """.formatted(to_language, word, conversor.getFormat());
        };

        return chatClient.prompt()
                .user(prompt)
                .call()
                .entity(WrittenExerciseAiResponse.class);

    }


    private WrittenType randomExerciseType() {
        WrittenType[] types = WrittenType.values();
        return types[new java.util.Random().nextInt(types.length)];
    }

}
