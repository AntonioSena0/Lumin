package br.com.api.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record WordRequest (

        @NotNull(message = "A palavra não pode ser nula")
        @NotEmpty(message = "Para salvar uma palavra você precisa detectar um objeto")
        @Size(max = 100, message = "A palavra tem mais de 100 caracteres")
        String original,

        @NotNull(message = "A tradução não pode ser nula")
        @NotEmpty(message = "Para salvar uma palavra você precisa detectar um objeto")
        @Size(max = 100, message = "A tradução tem mais de 100 caracteres")
        String translated,

        @Size(max = 200, message = "A descrição tem mais de 200 caracteres")
        String description,

        @NotNull(message = "A categoria não pode ser nula")
        Integer categoryId

){}
