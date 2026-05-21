package br.com.api.service;

import br.com.api.dto.response.LanguageResponse;

import java.util.List;

public interface LanguageService {

    List<LanguageResponse> findAll();
    LanguageResponse findById(Integer id);

}
