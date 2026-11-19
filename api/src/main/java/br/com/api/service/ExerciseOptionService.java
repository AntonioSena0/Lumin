package br.com.api.service;

import br.com.api.entity.Word;

import java.util.List;

public interface ExerciseOptionService {

    List<String> buildMultipleChoiceOptions(Word word, List<String> aiOptions);
    List<String> buildWordBank(String correctAnswer, Word word, List<String> aiOptions);
    List<String> buildSentenceBlocks(String correctSentence, Word word);

}
