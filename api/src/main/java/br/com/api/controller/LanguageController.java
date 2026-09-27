package br.com.api.controller;

import br.com.api.dto.response.LanguageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "Language", description = "Recurso responsável pelos idiomas.")
public interface LanguageController {

    @Operation(summary = "Listar idiomas", description = "Método responsável por listar os idiomas disponíveis")
    @ApiResponse(responseCode = "200", description = "Idiomas encontrados",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = LanguageResponse.class))))
    ResponseEntity<List<LanguageResponse>> findAll();

    @Operation(summary = "Buscar idioma", description = "Método responsável por retornar um idioma pelo identificador único")
    @ApiResponse(responseCode = "200", description = "Idioma encontrado",
            content = @Content(schema = @Schema(implementation = LanguageResponse.class)))
    @ApiResponse(responseCode = "404", description = "Idioma não encontrado", content = @Content())
    ResponseEntity<LanguageResponse> findById(Integer id);
}
