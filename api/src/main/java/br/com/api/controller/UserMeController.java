package br.com.api.controller;

import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPatchRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.response.UserMeResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Me", description = "Recurso responsável pelos dados do usuário autenticado.")
public interface UserMeController {

    @Operation(summary = "Buscar perfil próprio", description = "Método responsável por retornar os dados do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Usuário encontrado",
            content = @Content(schema = @Schema(implementation = UserMeResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<UserMeResponse> findById();

    @Operation(summary = "Atualizar perfil próprio", description = "Método responsável pela atualização completa dos dados do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Usuário atualizado",
            content = @Content(schema = @Schema(implementation = UserMeResponse.class)))
    @ApiResponse(responseCode = "400", description = "Dados inválidos", content = @Content())
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<UserMeResponse> update(UserPutRequest request);

    @Operation(summary = "Atualizar perfil próprio parcialmente", description = "Método responsável pela atualização parcial dos dados do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Usuário atualizado",
            content = @Content(schema = @Schema(implementation = UserMeResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<UserMeResponse> parcialUpdate(UserPatchRequest request);

    @Operation(summary = "Trocar avatar próprio", description = "Método responsável pela troca do avatar do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Avatar atualizado",
            content = @Content(schema = @Schema(implementation = UserMeResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Avatar não encontrado", content = @Content())
    ResponseEntity<UserMeResponse> changeAvatar(AvatarChangeRequest request);

    @Operation(summary = "Excluir conta própria", description = "Método responsável pela exclusão da conta do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "204", description = "Conta excluída", content = @Content())
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<Void> delete();
}
