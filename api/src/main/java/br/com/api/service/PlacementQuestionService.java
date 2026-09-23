package br.com.api.service;

import br.com.api.dto.request.PlacementTestSubmitRequest;
import br.com.api.dto.response.PlacementQuestionResponse;
import br.com.api.dto.response.PlacementTestResultResponse;

import java.util.List;

public interface PlacementQuestionService {

    List<PlacementQuestionResponse> findByLanguage(Integer languageId);
    PlacementTestResultResponse submit(Long userId, Integer languageId, PlacementTestSubmitRequest request);

}
