package br.com.api.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

public record PlacementTestAnswerRequest(

        @NotNull(message = "Id da questão é obrigatório")
        Long questionId,

        @NotNull(message = "A resposta é obrigatória")
        @NotEmpty(message = "A resposta não pode estar vazia")
        String answer

) {}
