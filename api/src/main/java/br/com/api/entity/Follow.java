package br.com.api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "follows")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class Follow {

    @EmbeddedId
    private FollowId id;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

}
