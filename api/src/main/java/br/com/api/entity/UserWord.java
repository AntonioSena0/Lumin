package br.com.api.entity;

import br.com.api.domain.WordDomainLevel;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcType;
import org.hibernate.dialect.PostgreSQLEnumJdbcType;
import org.hibernate.type.descriptor.jdbc.EnumJdbcType;

import java.time.LocalDateTime;

@Entity
@Table(name = "users_words")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class UserWord {

    @EmbeddedId
    private UserWordId id;

    @MapsId("userId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @MapsId("wordId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "word_id", nullable = false)
    private Word word;

    @Column(name = "correct_answers", nullable = false)
    private Long correctAnswers;

    @Column(name = "incorrect_answers", nullable = false)
    private Long incorrectAnswers;

    @JdbcType(PostgreSQLEnumJdbcType.class)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private WordDomainLevel level;

    @Column(name = "last_practiced")
    private LocalDateTime lastPracticed;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

}
