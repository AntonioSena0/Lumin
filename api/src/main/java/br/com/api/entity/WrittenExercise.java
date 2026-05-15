package br.com.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Entity
@Table(name = "written_exercises")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class WrittenExercise extends Exercise{

    @Column(name = "correct_answer", nullable = false)
    private String correctAnswer;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<String> options;

    @Override
    public boolean checkAnswer(String answer) {
        return answer != null && answer.trim().equalsIgnoreCase(correctAnswer.trim());
    }

    @Override
    public String getCorrectAnswer() {
        return correctAnswer;
    }
}
