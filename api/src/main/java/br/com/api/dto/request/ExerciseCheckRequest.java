package br.com.api.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

public record ExerciseCheckRequest(

        @NotEmpty(message = "A resposta é obrigatória")
        @Size(max = 150, message = "A resposta só pode ter até 150 caracteres")
        String answer

) {}
