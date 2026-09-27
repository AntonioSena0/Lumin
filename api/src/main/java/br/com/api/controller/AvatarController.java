package br.com.api.controller;

import br.com.api.dto.response.AvatarResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "Avatar", description = "Recurso responsável pelos avatares.")
public interface AvatarController {

    @Operation(summary = "Listar avatares", description = "Método responsável por listar os avatares disponíveis")
    @ApiResponse(responseCode = "200", description = "Avatares encontrados",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = AvatarResponse.class))))
    ResponseEntity<List<AvatarResponse>> findAll();

    @Operation(summary = "Buscar avatar", description = "Método responsável por retornar um avatar pelo identificador único")
    @ApiResponse(responseCode = "200", description = "Avatar encontrado",
            content = @Content(schema = @Schema(implementation = AvatarResponse.class)))
    @ApiResponse(responseCode = "404", description = "Avatar não encontrado", content = @Content())
    ResponseEntity<AvatarResponse> findById(Integer id);
}
