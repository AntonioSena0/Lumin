package br.com.api.mapper;

import br.com.api.dto.response.CategoryProgressResponse;
import br.com.api.repository.projection.CategoryProgressProjection;
import lombok.experimental.UtilityClass;

@UtilityClass
public class CategoryProgressMapper {

    public CategoryProgressResponse toCategoryProgressResponse(CategoryProgressProjection projection) {
        long correctAnswers = projection.getCorrectAnswers();
        long incorrectAnswers = projection.getIncorrectAnswers();
        long totalAnswers = correctAnswers + incorrectAnswers;

        double accuracy = totalAnswers == 0
                ? 0.0
                : (double) correctAnswers / totalAnswers;

        return CategoryProgressResponse
                .builder()
                .categoryId(projection.getCategoryId())
                .categoryName(projection.getCategoryName())
                .categoryDescription(projection.getCategoryDescription())
                .totalWords(projection.getTotalWords())
                .savedWords(projection.getSavedWords())
                .practicedWords(projection.getPracticedWords())
                .weakWords(projection.getWeakWords())
                .discoveredWords(projection.getDiscoveredWords())
                .practicingWords(projection.getPracticingWords())
                .familiarWords(projection.getFamiliarWords())
                .correctAnswers(projection.getCorrectAnswers())
                .incorrectAnswers(projection.getIncorrectAnswers())
                .accuracy(Math.round(accuracy * 100.0) / 100.0)
                .lastPracticed(projection.getLastPracticed())
                .build();
    }

}
