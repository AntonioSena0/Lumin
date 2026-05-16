package br.com.api.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record WordUpdateRequest(

        @NotNull(message = "A descrição não pode ser nula")
        @NotEmpty(message = "A descrição não pode ser vazia")
        @Size(max = 200, message = "A descrição tem mais de 200 caracteres")
        String description

) {}
