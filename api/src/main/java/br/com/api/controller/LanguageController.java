package br.com.api.controller;

import br.com.api.dto.response.LanguageResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface LanguageController {

    ResponseEntity<List<LanguageResponse>> findAll();
    ResponseEntity<LanguageResponse> findById(Integer id);

}
