package br.com.api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users", indexes = {
        @Index(name = "idx_user_name", columnList = "name", unique = true),
        @Index(name = "idx_user_email", columnList = "email", unique = true)
})
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "native_language_id", nullable = false)
    private Language nativeLanguage;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "to_language_id", nullable = false)
    private Language chosenLanguage;

    @OneToMany(mappedBy = "user")
    @BatchSize(size = 10)
    private List<UserWord> words;

    @OneToMany(mappedBy = "user")
    @BatchSize(size = 10)
    private List<StudySession> sessions;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

}
