package br.com.api.service;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.dto.response.WordResponse;

import java.util.List;

public interface WordService {

    List<WordResponse> findAll();
    WordResponse findById(Long wordId);
    List<WordResponse> search(String q, Integer languageId);
    UserWordListResponse save(WordRequest request, Long userId);
    UserWordListResponse unsave(Long wordId, Long userId);

}
