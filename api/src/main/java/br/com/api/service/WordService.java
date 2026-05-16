package br.com.api.service;

import br.com.api.dto.WordRequest;
import br.com.api.dto.WordResponse;
import br.com.api.dto.WordUpdateRequest;

import java.util.List;

public interface WordService {

    List<WordResponse> findAll();
    WordResponse findById(Long wordId);
    List<WordResponse> search(String q);
    WordResponse save(WordRequest request, Long userId);
    WordResponse update(WordUpdateRequest request, Long wordId);
    void unsave(Long wordId, Long userId);

}
