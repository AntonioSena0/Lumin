package br.com.api.controller;

import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.PublicProfileResponse;
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
    ResponseEntity<PageResponse<UserResponse>> findAll(String q, Pageable pageable);

    @Operation(summary = "Buscar usuário", description = "Método responsável por retornar um usuário pelo identificador único",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Usuário encontrado",
            content = @Content(schema = @Schema(implementation = UserResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Usuário não encontrado", content = @Content())
    ResponseEntity<UserResponse> findById(Long id);

    @Operation(summary = "Perfil público", description = "Perfil de outro usuário com seguidores, seguindo e se você o segue",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Perfil encontrado",
            content = @Content(schema = @Schema(implementation = PublicProfileResponse.class)))
    @ApiResponse(responseCode = "404", description = "Usuário não encontrado", content = @Content())
    ResponseEntity<PublicProfileResponse> profile(Long id);

    @Operation(summary = "Seguir usuário", security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "204", description = "Seguindo", content = @Content())
    @ApiResponse(responseCode = "404", description = "Usuário não encontrado", content = @Content())
    @ApiResponse(responseCode = "422", description = "Não é possível seguir a si mesmo", content = @Content())
    ResponseEntity<Void> follow(Long id);

    @Operation(summary = "Deixar de seguir usuário", security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "204", description = "Deixou de seguir", content = @Content())
    ResponseEntity<Void> unfollow(Long id);

    @Operation(summary = "Seguidores", security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Seguidores do usuário",
            content = @Content(schema = @Schema(implementation = PageResponse.class)))
    ResponseEntity<PageResponse<UserResponse>> followers(Long id, Pageable pageable);

    @Operation(summary = "Seguindo", security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Usuários que ele segue",
            content = @Content(schema = @Schema(implementation = PageResponse.class)))
    ResponseEntity<PageResponse<UserResponse>> following(Long id, Pageable pageable);
}
