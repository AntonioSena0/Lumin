package br.com.api.controller;

import br.com.api.dto.response.CategoryProgressResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "CategoryProgress", description = "Recurso responsável pelo progresso por categoria.")
public interface CategoryProgressController {

    @Operation(summary = "Progresso por categoria", description = "Método responsável por listar o progresso por categoria do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Progresso encontrado",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = CategoryProgressResponse.class))))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<List<CategoryProgressResponse>> findByUserId();
}
