package br.com.api.controller;

import br.com.api.dto.request.*;
import br.com.api.dto.response.OAuthPendingResponse;
import br.com.api.dto.response.UserMeResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Auth", description = "Recurso responsável pela autenticação com cookies HttpOnly.")
public interface AuthController {

    @Operation(summary = "Registrar usuário", description = "Método responsável por criar um novo usuário e emitir os cookies de sessão")
    @ApiResponse(responseCode = "201", description = "Usuário registrado",
            content = @Content(schema = @Schema(implementation = UserMeResponse.class)))
    @ApiResponse(responseCode = "400", description = "Dados inválidos", content = @Content())
    @ApiResponse(responseCode = "409", description = "Dados já em uso", content = @Content())
    ResponseEntity<UserMeResponse> register(UserRequest request);

    @Operation(summary = "Entrar", description = "Método responsável por autenticar o usuário e emitir os cookies de sessão")
    @ApiResponse(responseCode = "204", description = "Autenticado", content = @Content())
    @ApiResponse(responseCode = "401", description = "Credenciais inválidas", content = @Content())
    ResponseEntity<Void> login(LoginRequest request);

    @Operation(summary = "Renovar sessão", description = "Método responsável por rotacionar o par access/refresh")
    @ApiResponse(responseCode = "204", description = "Sessão renovada", content = @Content())
    @ApiResponse(responseCode = "401", description = "Sessão inválida", content = @Content())
    ResponseEntity<Void> refresh(String refresh);

    @Operation(summary = "Sair", description = "Método responsável por revogar o refresh e limpar os cookies")
    @ApiResponse(responseCode = "204", description = "Sessão encerrada", content = @Content())
    ResponseEntity<Void> logout(String refresh);

    @Operation(summary = "Entrar com provedor social", description = "Método responsável por autenticar via Google ou retornar os dados para concluir o cadastro")
    @ApiResponse(responseCode = "204", description = "Autenticado", content = @Content())
    @ApiResponse(responseCode = "202", description = "Conta nova, concluir cadastro",
            content = @Content(schema = @Schema(implementation = OAuthPendingResponse.class)))
    @ApiResponse(responseCode = "422", description = "Login social inválido", content = @Content())
    ResponseEntity<OAuthPendingResponse> oauth(OAuthRequest request);

    ResponseEntity<UserMeResponse> registerOAuth(UserOAuthRequest request);

    @Operation(summary = "Verificar código", description = "Método responsável por confirmar o e-mail com o código enviado")
    @ApiResponse(responseCode = "204", description = "E-mail verificado", content = @Content())
    @ApiResponse(responseCode = "422", description = "Código inválido", content = @Content())
    ResponseEntity<Void> verify(VerifyRequest request);

    @Operation(summary = "Reenviar código", description = "Método responsável por reenviar o código de verificação")
    @ApiResponse(responseCode = "204", description = "Código reenviado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Usuário não encontrado", content = @Content())
    @ApiResponse(responseCode = "429", description = "Aguarde antes de reenviar", content = @Content())
    ResponseEntity<Void> resend(ResendRequest request);

}
