package br.com.api.controller;

import br.com.api.dto.response.CategoryResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "Category", description = "Recurso responsável pelas categorias.")
public interface CategoryController {

    @Operation(summary = "Listar categorias", description = "Método responsável por listar as categorias",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Categorias encontradas",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = CategoryResponse.class))))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<List<CategoryResponse>> findAll();

    @Operation(summary = "Buscar categoria", description = "Método responsável por retornar uma categoria pelo identificador único",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Categoria encontrada",
            content = @Content(schema = @Schema(implementation = CategoryResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Categoria não encontrada", content = @Content())
    ResponseEntity<CategoryResponse> findById(Integer id);
}
