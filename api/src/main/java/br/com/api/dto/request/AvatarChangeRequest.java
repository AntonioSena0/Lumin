package br.com.api.dto.request;

import jakarta.validation.constraints.NotNull;

public record AvatarChangeRequest(

        @NotNull(message = "O avatar é obrigatório")
        Integer avatarId

) {}
