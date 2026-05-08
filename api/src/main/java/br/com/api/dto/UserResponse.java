package br.com.api.dto;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UserResponse(

        Long id,
        String name,
        String email,
        LocalDateTime createdAt,
        LocalDateTime updatedAt

) {}
