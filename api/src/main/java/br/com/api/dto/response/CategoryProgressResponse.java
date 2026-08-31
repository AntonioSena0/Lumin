package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record CategoryProgressResponse(

        Integer categoryId,
        String categoryName,
        String categoryDescription,
        Long totalWords,
        Long savedWords,
        Long practicedWords,
        Long weakWords,
        Long discoveredWords,
        Long practicingWords,
        Long familiarWords,
        Long correctAnswers,
        Long incorrectAnswers,
        Double accuracy,
        LocalDateTime lastPracticed

) {}
