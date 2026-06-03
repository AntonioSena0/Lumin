package br.com.api.service;

import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.entity.Word;

public interface AiGeneratorService {

    String generateDescription(String original, String translated, String category, String language);
    StudySessionAiResponse generateStudySession(Word word, String fromLanguage, String toLanguage);

}
