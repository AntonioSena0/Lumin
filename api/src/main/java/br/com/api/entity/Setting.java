package br.com.api.entity;

import br.com.api.domain.VoiceType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcType;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.dialect.PostgreSQLEnumJdbcType;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_settings")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Setting {

    @Id
    private Long userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "app_language_id", nullable = false)
    private Language appLanguage;

    @Builder.Default
    @Column(name = "notify_daily", nullable = false)
    private boolean notifyDaily = true;

    @Builder.Default
    @Column(name = "notify_review", nullable = false)
    private boolean notifyReview = true;

    @Builder.Default
    @JdbcType(PostgreSQLEnumJdbcType.class)
    @Enumerated(value = EnumType.STRING)
    @Column(nullable = false)
    private VoiceType voice = VoiceType.FEMALE;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

}
