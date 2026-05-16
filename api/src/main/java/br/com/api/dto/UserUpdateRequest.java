package br.com.api.dto;

import br.com.api.entity.Language;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public record UserUpdateRequest(

        @Size(max = 100, message = "O nome de usuário só pode ter até 100 caracteres")
        String name,

        @Size(max = 100, message = "O email só pode ter até 100 caracteres")
        @Email(message = "Formato de email incorreto")
        String email,

        @Size(min = 8, max = 100, message = "A senha deve ter de 8 à 100 caracteres")
        String password,

        Integer nativeLanguage,

        Integer chosenLanguage

) {}
