package br.com.api.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "avatars")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class Avatar {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String name;

    @Column(name = "img_url", nullable = false, unique = true)
    private String imgUrl;

}
