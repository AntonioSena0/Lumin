package br.com.api.controller;

import br.com.api.dto.request.PlacementTestSubmitRequest;
import br.com.api.dto.response.PlacementQuestionResponse;
import br.com.api.dto.response.PlacementTestResultResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "Placement", description = "Recurso responsável pelo teste de nivelamento.")
public interface PlacementQuestionController {

    @Operation(summary = "Listar questões", description = "Método responsável por listar as questões de nivelamento de um idioma",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Questões encontradas",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = PlacementQuestionResponse.class))))
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    @ApiResponse(responseCode = "404", description = "Nenhuma questão encontrada", content = @Content())
    ResponseEntity<List<PlacementQuestionResponse>> findByLanguageId(Integer languageId);

    @Operation(summary = "Enviar respostas", description = "Método responsável por corrigir o teste e definir o nível inicial",
            security = @SecurityRequirement(name = "cookieAuth"))
    @ApiResponse(responseCode = "200", description = "Resultado calculado",
            content = @Content(schema = @Schema(implementation = PlacementTestResultResponse.class)))
    @ApiResponse(responseCode = "400", description = "Respostas inválidas", content = @Content())
    @ApiResponse(responseCode = "401", description = "Não autenticado", content = @Content())
    ResponseEntity<PlacementTestResultResponse> submit(Integer languageId, PlacementTestSubmitRequest request);
}
