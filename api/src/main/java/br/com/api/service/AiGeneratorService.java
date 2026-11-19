package br.com.api.service;

import br.com.api.domain.UserLanguageLevel;
import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.dto.response.WordInsightAiResponse;
import br.com.api.entity.Word;

import java.util.List;

public interface AiGeneratorService {

    WordInsightAiResponse generateWordInsight(String original, String translated, String chosenCategory, List<String> categories, String language);
    StudySessionAiResponse generateStudySession(Word word, String fromLanguage, String toLanguage, UserLanguageLevel level, String weakContext);

}
