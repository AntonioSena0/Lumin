package br.com.api.dto.request;

import jakarta.validation.constraints.*;

public record UserRequest(

        @NotEmpty(message = "O nome de usuário não pode estar vazio")
        @Size(max = 100, message = "O nome de usuário só pode ter até 100 caracteres")
        String name,

        @NotEmpty(message = "O email não pode estar vazio")
        @Size(max = 100, message = "O email só pode ter até 100 caracteres")
        @Email(message = "Formato de email incorreto")
        String email,

        @NotEmpty(message = "A senha não pode estar vazia")
        @Size(min = 8, max = 100, message = "A senha deve ter de 8 à 100 caracteres")
        String password,

        @NotNull(message = "A língua nativa é obrigatória")
        Integer nativeLanguage,

        @NotNull(message = "A linguagem de preferência é obrigatória")
        Integer chosenLanguage

) {}
