package br.com.api.service;

import br.com.api.entity.Word;
import br.com.api.repository.WordRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@AllArgsConstructor
public class ExerciseOptionServiceImpl implements ExerciseOptionService{

    private final WordRepository wordRepository;

    @Override
    public List<String> buildMultipleChoiceOptions(Word word, List<String> aiOptions) {
        String correctAnswer = normalize(word.getTranslated());

        Set<String> options = new LinkedHashSet<>();

        options.add(correctAnswer);

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
                .map(Word::getTranslated)
                .map(this::normalize)
                .filter(option -> !option.isBlank())
                .filter(option -> !option.equalsIgnoreCase(word.getTranslated()))
                .forEach(options::add);

        List<String> fallbackOptions = new ArrayList<>(List.of(
                "tool", "device", "item", "material", "accessory", "product"
        ));

        Collections.shuffle(fallbackOptions);

        int missingOptions = 4 - options.size();

        if(missingOptions > 0){
            options.addAll(
                    fallbackOptions.subList(
                            0,
                            Math.min(missingOptions, fallbackOptions.size())
                    )
            );
        }

        return options.stream()
                .limit(4)
                .toList();
    }

    private String normalize(String value) {
        return value == null ? "" : value.toLowerCase().trim();
    }

}
