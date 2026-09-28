package br.com.api.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record VerifyRequest(

        @NotBlank(message = "O email não pode estar vazio")
        @Email(message = "Formato de email incorreto")
        String email,

        @NotBlank(message = "O código não pode estar vazio")
        @Size(min = 6, max = 6)
        String code

) {}
