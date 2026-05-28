package br.com.api.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record WordUpdateRequest(

        @Size(max = 200, message = "A descrição tem mais de 200 caracteres")
        String description,

        Integer categoryId

) {}
