package br.com.api.service;

import br.com.api.dto.response.SpeakingExerciseAiResponse;
import br.com.api.entity.Language;
import br.com.api.entity.SpeakingExercise;
import br.com.api.entity.Word;

import java.util.List;

public interface SpeakingExerciseService {

    List<SpeakingExercise> saveAllSpeakingExercises(List<SpeakingExerciseAiResponse> exercises, Language language, Word word);

}
