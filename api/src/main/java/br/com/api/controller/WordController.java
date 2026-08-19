package br.com.api.controller;

import br.com.api.dto.response.WordResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface WordController {

    ResponseEntity<List<WordResponse>> findAll();
    ResponseEntity<WordResponse> findById(Long wordId);
    ResponseEntity<List<WordResponse>> search(Integer languageId, String q);

}
