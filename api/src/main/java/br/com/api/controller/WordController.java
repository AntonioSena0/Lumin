package br.com.api.controller;

import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.WordResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

@Tag(name = "Word", description = "Recurso responsável pelo catálogo de palavras.")
public interface WordController {

    @Operation(summary = "Listar palavras", description = "Método responsável por listar as palavras com paginação",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Palavras encontradas",
            content = @Content(schema = @Schema(implementation = PageResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<PageResponse<WordResponse>> findAll(Pageable pageable);

    @Operation(summary = "Buscar palavra", description = "Método responsável por retornar uma palavra pelo identificador único",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Palavra encontrada",
            content = @Content(schema = @Schema(implementation = WordResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Palavra não encontrada", content = @Content())
    ResponseEntity<WordResponse> findById(Long wordId);

    @Operation(summary = "Pesquisar palavras", description = "Método responsável por pesquisar palavras pelo texto original",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Palavras encontradas",
            content = @Content(schema = @Schema(implementation = PageResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<PageResponse<WordResponse>> search(Integer languageId, String q, Pageable pageable);
}
