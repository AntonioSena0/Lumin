package br.com.api.controller;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.WordResponse;
import br.com.api.dto.request.WordUpdateRequest;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface WordController {

    ResponseEntity<List<WordResponse>> findAll();
    ResponseEntity<WordResponse> findById(Long wordId);
    ResponseEntity<List<WordResponse>> search(String q);
    ResponseEntity<WordResponse> save(WordRequest request, Long userId);
    ResponseEntity<WordResponse> update(WordUpdateRequest request, Long wordId);
    ResponseEntity<Void> unsave(Long wordId, Long userId);

}
