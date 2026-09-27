package br.com.api.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record LoginRequest(

        @NotEmpty(message = "Email não pode estar vazio")
        @Size(max = 100, message = "O email só pode ter até 100 caracteres")
        @Email(message = "Formato de email incorreto")
        String email,

        @NotEmpty(message = "Senha não pode estar vazia")
        @Size(min = 8, max = 100, message = "A senha deve ter de 8 à 100 caracteres")
        String password

) {}
