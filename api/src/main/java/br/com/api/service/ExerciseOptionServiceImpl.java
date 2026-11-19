package br.com.api.service;

import br.com.api.entity.Word;
import br.com.api.repository.WordRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@AllArgsConstructor
public class ExerciseOptionServiceImpl implements ExerciseOptionService{

    private static final int SENTENCE_DISTRACTORS = 3;

    private final WordRepository wordRepository;

    /** Monta as 4 alternativas da múltipla escolha a partir da tradução da palavra. */
    @Override
    public List<String> buildMultipleChoiceOptions(Word word, List<String> aiOptions) {
        return buildWordBank(word.getTranslated(), word, aiOptions);
    }

    /** Monta 4 alternativas embaralhadas: a resposta correta e distratores da IA, da mesma categoria ou genéricos. */
    @Override
    public List<String> buildWordBank(String correctAnswer, Word word, List<String> aiOptions) {
        String correct = normalize(correctAnswer);

        Set<String> options = new LinkedHashSet<>();
        options.add(correct);
        distractors(word, aiOptions).stream()
                .filter(option -> !option.equalsIgnoreCase(correct))
                .forEach(options::add);

        List<String> fallbackOptions = new ArrayList<>(List.of(
                "tool", "device", "item", "material", "accessory", "product"
        ));
        Collections.shuffle(fallbackOptions);
        fallbackOptions.stream()
                .filter(option -> options.size() < 4)
                .forEach(options::add);

        List<String> result = new ArrayList<>(options.stream().limit(4).toList());
        Collections.shuffle(result);
        return result;
    }

    /** Quebra a frase correta em blocos de palavras e mistura com distratores para o usuário montar a resposta. */
    @Override
    public List<String> buildSentenceBlocks(String correctSentence, Word word) {
        List<String> blocks = new ArrayList<>(Arrays.stream((correctSentence == null ? "" : correctSentence).trim().split("\\s+"))
                .map(token -> token.replaceAll("^[^\\p{L}\\p{N}']+|[^\\p{L}\\p{N}']+$", ""))
                .filter(token -> !token.isBlank())
                .toList());

        distractors(word, List.of()).stream()
                .filter(option -> !option.contains(" "))
                .filter(option -> blocks.stream().noneMatch(block -> block.equalsIgnoreCase(option)))
                .limit(SENTENCE_DISTRACTORS)
                .forEach(blocks::add);

        Collections.shuffle(blocks);
        return blocks;
    }

    /** Reúne distratores sugeridos pela IA e traduções de outras palavras da mesma categoria e idioma. */
    private List<String> distractors(Word word, List<String> aiOptions) {
        Set<String> options = new LinkedHashSet<>();

        if (aiOptions != null) {
            aiOptions.stream()
                    .map(this::normalize)
                    .filter(option -> !option.isBlank())
                    .forEach(options::add);
        }

        wordRepository.findTop10ByCategoryIdAndToLanguageIdAndIdNot(
                        word.getCategory().getId(),
                        word.getToLanguage().getId(),
                        word.getId()
                )
                .stream()
                .map(this::normalize)
                .filter(option -> !option.isBlank())
                .filter(option -> !option.equalsIgnoreCase(word.getTranslated()))
                .forEach(options::add);

        return new ArrayList<>(options);
    }

    private String normalize(String value) {
        return value == null ? "" : value.toLowerCase().trim();
    }

}
