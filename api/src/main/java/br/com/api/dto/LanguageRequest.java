package br.com.api.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record LanguageRequest (

        @NotEmpty(message = "O nome da língua é obrigatório")
        @Size(max = 100, message = "O nome da lingua só pode ter até 100 caracteres")
        String name,

        @NotEmpty(message = "O código da língua é obrigatório")
        @Size(max = 3, message = "O código da língua só pode ter até 3 caracteres")
        String code

) {}
