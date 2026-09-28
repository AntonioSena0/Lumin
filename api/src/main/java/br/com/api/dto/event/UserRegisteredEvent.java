package br.com.api.dto.event;

import lombok.Builder;

@Builder
public record UserRegisteredEvent(

        String email,
        String name,
        String code

) {}
