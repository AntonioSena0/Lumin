package br.com.api.controller;

import br.com.api.dto.request.SettingUpdateRequest;
import br.com.api.dto.response.SettingResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Setting", description = "Recurso responsável pelas configurações do usuário autenticado.")
public interface SettingController {

    @Operation(summary = "Buscar configurações", description = "Método responsável por retornar as configurações do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Configurações encontradas",
            content = @Content(schema = @Schema(implementation = SettingResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Configuração não encontrada", content = @Content())
    ResponseEntity<SettingResponse> findByUserId();

    @Operation(summary = "Atualizar configurações", description = "Método responsável pela atualização parcial das configurações",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Configurações atualizadas",
            content = @Content(schema = @Schema(implementation = SettingResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<SettingResponse> updateSettings(SettingUpdateRequest request);
}
