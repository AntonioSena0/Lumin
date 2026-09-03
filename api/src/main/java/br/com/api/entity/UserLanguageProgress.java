package br.com.api.entity;

import br.com.api.domain.UserLanguageLevel;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcType;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.dialect.PostgreSQLEnumJdbcType;

import java.time.LocalDateTime;

@Entity
@Table(name = "users_languages_progress")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserLanguageProgress {

    @EmbeddedId
    private UserLanguageProgressId id;

    @MapsId("userId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @MapsId("languageId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "language_id", nullable = false)
    private Language language;

    @JdbcType(PostgreSQLEnumJdbcType.class)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserLanguageLevel level;

    @Builder.Default
    @Column(nullable = false)
    private Long xp = 0L;

    @Builder.Default
    @Column(name = "total_sessions", nullable = false)
    private Long totalSessions = 0L;

    @Builder.Default
    @Column(name = "total_correct_answers", nullable = false)
    private Long totalCorrectAnswers = 0L;

    @Builder.Default
    @Column(name = "total_incorrect_answers", nullable = false)
    private Long totalIncorrectAnswers = 0L;

    @Column(name = "last_practiced")
    private LocalDateTime lastPracticed;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

}
