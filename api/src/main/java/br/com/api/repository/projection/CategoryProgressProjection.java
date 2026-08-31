package br.com.api.repository.projection;

import java.time.LocalDateTime;

public interface CategoryProgressProjection {

    Integer getCategoryId();

    String getCategoryName();

    String getCategoryDescription();

    Long getTotalWords();

    Long getSavedWords();

    Long getPracticedWords();

    Long getWeakWords();

    Long getDiscoveredWords();

    Long getPracticingWords();

    Long getFamiliarWords();

    Long getCorrectAnswers();

    Long getIncorrectAnswers();

    LocalDateTime getLastPracticed();

}
