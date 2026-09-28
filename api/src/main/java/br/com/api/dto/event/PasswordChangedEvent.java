package br.com.api.dto.event;

import lombok.Builder;

@Builder
public record PasswordChangedEvent(
        String email,
        String name
) {}
