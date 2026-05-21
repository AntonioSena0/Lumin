package br.com.api.entity;

import br.com.api.domain.WrittenType;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.JdbcType;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.dialect.PostgreSQLEnumJdbcType;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Entity
@Table(name = "written_exercises")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@SuperBuilder
public class WrittenExercise extends Exercise{

    @JdbcType(PostgreSQLEnumJdbcType.class)
    @Enumerated(EnumType.STRING)
    @Column(name = "sub_type")
    public WrittenType subType;

    @Column(name = "correct_answer", nullable = false)
    private String correctAnswer;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<String> options;

    @Override
    public boolean checkAnswer(String answer) {

        if (answer == null) return false;

        return answer.trim()
                .toLowerCase()
                .replaceAll("\\.$", "")
                .equalsIgnoreCase(correctAnswer
                                    .trim()
                                    .toLowerCase()
                                    .replaceAll("\\.$", "")
                );

    }

    @Override
    public String getCorrectAnswer() {
        return correctAnswer;
    }
}
