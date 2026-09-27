package br.com.api.controller;

import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.WordResponse;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

public interface WordController {

    ResponseEntity<PageResponse<WordResponse>> findAll(Pageable pageable);
    ResponseEntity<WordResponse> findById(Long wordId);
    ResponseEntity<PageResponse<WordResponse>> search(Integer languageId, String q, Pageable pageable);

}
