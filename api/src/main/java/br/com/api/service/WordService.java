package br.com.api.service;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.WordResponse;

import java.util.List;

public interface WordService {

    List<WordResponse> findAll();
    WordResponse findById(Long wordId);
    List<WordResponse> search(String q, Integer languageId);
    WordResponse save(WordRequest request, Long userId);
    void unsave(Long wordId, Long userId);

}
