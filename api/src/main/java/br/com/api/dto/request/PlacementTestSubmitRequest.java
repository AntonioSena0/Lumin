package br.com.api.dto.request;

import java.util.List;

public record PlacementTestSubmitRequest(

        List<PlacementTestAnswerRequest> answers

) {}
