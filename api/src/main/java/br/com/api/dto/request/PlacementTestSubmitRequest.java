package br.com.api.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record PlacementTestSubmitRequest(

        @NotEmpty(message = "As respostas não podem ser vazias")
        @NotNull(message = "As respostas não podem ser nulas")
        List<@Valid PlacementTestAnswerRequest> answers

) {}
