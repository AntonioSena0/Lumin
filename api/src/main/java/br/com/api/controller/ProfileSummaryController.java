package br.com.api.controller;

import br.com.api.dto.response.ProfileSummaryResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Profile", description = "Recurso responsável pelo resumo do perfil.")
public interface ProfileSummaryController {

    @Operation(summary = "Resumo do perfil", description = "Método responsável por retornar o resumo do perfil do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Resumo encontrado",
            content = @Content(schema = @Schema(implementation = ProfileSummaryResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<ProfileSummaryResponse> findByUserId();
}
