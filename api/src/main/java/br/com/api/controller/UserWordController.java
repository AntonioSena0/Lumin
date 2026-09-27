package br.com.api.controller;

import br.com.api.domain.WordDomainLevel;
import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.UserWordListResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

@Tag(name = "UserWord", description = "Recurso responsável pelas palavras do usuário autenticado.")
public interface UserWordController {

    @Operation(summary = "Buscar palavra do usuário", description = "Método responsável por retornar o vínculo do usuário com uma palavra",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Vínculo encontrado",
            content = @Content(schema = @Schema(implementation = UserWordListResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Vínculo não encontrado", content = @Content())
    ResponseEntity<UserWordListResponse> findUserWordById(Long wordId);

    @Operation(summary = "Listar palavras do usuário", description = "Método responsável por listar as palavras salvas com filtros",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Palavras encontradas",
            content = @Content(schema = @Schema(implementation = PageResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<PageResponse<UserWordListResponse>> findUserWords(
            Boolean saved,
            WordDomainLevel level,
            Integer categoryId,
            Integer languageId,
            String search,
            Boolean onlyPracticed,
            Boolean onlyWeak,
            Pageable pageable
    );

    @Operation(summary = "Salvar palavra", description = "Método responsável por salvar uma palavra para o usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "201", description = "Palavra salva",
            content = @Content(schema = @Schema(implementation = UserWordListResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<UserWordListResponse> save(WordRequest request);

    @Operation(summary = "Remover palavra dos salvos", description = "Método responsável por marcar a palavra como não salva",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Palavra atualizada",
            content = @Content(schema = @Schema(implementation = UserWordListResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<UserWordListResponse> unsave(Long wordId);
}
