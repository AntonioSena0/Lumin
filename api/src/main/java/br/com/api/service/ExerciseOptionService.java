package br.com.api.service;

import br.com.api.entity.Word;

import java.util.List;

public interface ExerciseOptionService {

    List<String> buildMultipleChoiceOptions(Word word, List<String> aiOptions);

}
