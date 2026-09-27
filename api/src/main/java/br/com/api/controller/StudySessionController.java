package br.com.api.controller;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.ExerciseCheckResponse;
import br.com.api.dto.response.ExerciseResponse;
import br.com.api.dto.response.StudySessionResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "StudySession", description = "Recurso responsável pelas sessões de estudo.")
public interface StudySessionController {

    @Operation(summary = "Buscar sessão", description = "Método responsável por retornar uma sessão de estudo do usuário autenticado",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Sessão encontrada",
            content = @Content(schema = @Schema(implementation = StudySessionResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Sessão não encontrada", content = @Content())
    @ApiResponse(responseCode = "422", description = "Sessão não pertence ao usuário", content = @Content())
    ResponseEntity<StudySessionResponse> findById(Long id);

    @Operation(summary = "Iniciar sessão", description = "Método responsável por gerar os exercícios de uma palavra",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "201", description = "Sessão criada",
            content = @Content(schema = @Schema(implementation = StudySessionResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Palavra não encontrada", content = @Content())
    ResponseEntity<StudySessionResponse> startSession(Long wordId);

    @Operation(summary = "Exercício atual", description = "Método responsável por retornar o exercício atual da sessão",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Exercício encontrado",
            content = @Content(schema = @Schema(implementation = ExerciseResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Sessão não encontrada", content = @Content())
    ResponseEntity<ExerciseResponse> currentExercise(Long studySessionId);

    @Operation(summary = "Responder exercício", description = "Método responsável por corrigir a resposta de um exercício",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Resposta corrigida",
            content = @Content(schema = @Schema(implementation = ExerciseCheckResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "422", description = "Exercício inválido para resposta", content = @Content())
    ResponseEntity<ExerciseCheckResponse> finishExercise(Long id, Long exerciseId, ExerciseCheckRequest request);

    @Operation(summary = "Finalizar sessão", description = "Método responsável por finalizar a sessão e somar o XP",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Sessão finalizada",
            content = @Content(schema = @Schema(implementation = StudySessionResponse.class)))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "422", description = "Sessão não pode ser finalizada", content = @Content())
    ResponseEntity<StudySessionResponse> finishSession(Long id);
}
