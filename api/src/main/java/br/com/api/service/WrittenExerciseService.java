package br.com.api.service;

import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.Language;
import br.com.api.entity.Word;
import br.com.api.entity.WrittenExercise;

import java.util.List;

public interface WrittenExerciseService {

    List<WrittenExercise> saveAllWrittenExercises(List<WrittenExerciseAiResponse> exercises, Language language, Word word);

}