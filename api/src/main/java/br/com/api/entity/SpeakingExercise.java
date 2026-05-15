package br.com.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Entity
@Table(name = "speaking_exercises")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class SpeakingExercise extends Exercise{

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "required_words", columnDefinition = "jsonb", nullable = false)
    private List<String> requiredWords;

    @Override
    public boolean checkAnswer(String answer) {
        if (answer == null || requiredWords == null) {
            return false;
        }
        String normalizedAnswer = answer.toLowerCase();
        return requiredWords.stream()
                .filter(word -> word != null && !word.isBlank())
                .allMatch(word -> normalizedAnswer.contains(word.toLowerCase()));
    }

    @Override
    public String getCorrectAnswer() {
        return this.getPrompt();
    }

}
