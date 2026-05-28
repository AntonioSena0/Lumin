package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record CategoryResponse(

        Integer id,
        String name,
        String description,
        LocalDateTime createdAt

) {}
