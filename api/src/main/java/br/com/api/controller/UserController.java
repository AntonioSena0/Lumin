package br.com.api.controller;

import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.UserResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

@Tag(name = "User", description = "Recurso responsável pelos usuários.")
public interface UserController {

    @Operation(summary = "Listar usuários", description = "Método responsável por listar usuários com paginação",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Usuários encontrados",
            content = @Content(schema = @Schema(implementation = PageResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<PageResponse<UserResponse>> findAll(Pageable pageable);

    @Operation(summary = "Buscar usuário", description = "Método responsável por retornar um usuário pelo identificador único",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Usuário encontrado",
            content = @Content(schema = @Schema(implementation = UserResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Usuário não encontrado", content = @Content())
    ResponseEntity<UserResponse> findById(Long id);
}
