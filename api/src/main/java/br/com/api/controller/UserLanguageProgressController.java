package br.com.api.controller;

import br.com.api.dto.response.UserLanguageProgressResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "Progress", description = "Recurso responsável pelo progresso por idioma do usuário autenticado.")
public interface UserLanguageProgressController {

    @Operation(summary = "Buscar progresso no idioma", description = "Método responsável por retornar o progresso em um idioma",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Progresso encontrado",
            content = @Content(schema = @Schema(implementation = UserLanguageProgressResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Progresso não encontrado", content = @Content())
    ResponseEntity<UserLanguageProgressResponse> findById(Integer languageId);

    @Operation(summary = "Listar progressos", description = "Método responsável por listar o progresso em todos os idiomas",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Progressos encontrados",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = UserLanguageProgressResponse.class))))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<List<UserLanguageProgressResponse>> findByUserId();

    @Operation(summary = "Criar progresso no idioma", description = "Método responsável por iniciar o progresso em um idioma",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "201", description = "Progresso criado",
            content = @Content(schema = @Schema(implementation = UserLanguageProgressResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<UserLanguageProgressResponse> getOrCreate(Integer languageId);
}
