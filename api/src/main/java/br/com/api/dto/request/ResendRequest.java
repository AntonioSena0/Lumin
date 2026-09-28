package br.com.api.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record ResendRequest(

        @NotBlank(message = "O email não pode estar vazio")
        @Email(message = "Formato de email incorreto")
        String email

) {}
