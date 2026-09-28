package br.com.api.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public record UserPatchRequest(

        @Size(max = 100, message = "O nome de usuário só pode ter até 100 caracteres")
        String name,

        @Size(max = 100, message = "O email só pode ter até 100 caracteres")
        @Email(message = "Formato de email incorreto")
        String email,

        Integer nativeLanguage,

        Integer chosenLanguage

) {}
