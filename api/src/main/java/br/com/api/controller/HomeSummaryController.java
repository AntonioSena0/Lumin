package br.com.api.controller;


import br.com.api.dto.response.HomeSummaryResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Home", description = "Recurso responsável pelo resumo da tela inicial.")
public interface HomeSummaryController {

    @Operation(summary = "Resumo da tela inicial", description = "Método responsável por retornar o resumo do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Resumo encontrado",
            content = @Content(schema = @Schema(implementation = HomeSummaryResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<HomeSummaryResponse> findByUserId();
}
