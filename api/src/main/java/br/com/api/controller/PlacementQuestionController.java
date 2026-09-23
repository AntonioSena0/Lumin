package br.com.api.controller;

import br.com.api.dto.request.PlacementTestSubmitRequest;
import br.com.api.dto.response.PlacementQuestionResponse;
import br.com.api.dto.response.PlacementTestResultResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface PlacementQuestionController {

    ResponseEntity<List<PlacementQuestionResponse>> findByLanguageId(Integer languageId);
    ResponseEntity<PlacementTestResultResponse> submit(Long userId, Integer languageId, PlacementTestSubmitRequest request);

}
