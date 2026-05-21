package br.com.api.service;

import br.com.api.dto.response.WrittenExerciseAiResponse;

public interface AiGeneratorService {

    WrittenExerciseAiResponse generateWrittenExercise(String word, String from_language, String to_language);

}
