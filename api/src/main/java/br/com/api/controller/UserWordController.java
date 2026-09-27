package br.com.api.controller;

import br.com.api.domain.WordDomainLevel;
import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.UserWordListResponse;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

public interface UserWordController {

    ResponseEntity<UserWordListResponse> findUserWordById(Long wordId);

    ResponseEntity<PageResponse<UserWordListResponse>> findUserWords(
            Boolean saved,
            WordDomainLevel level,
            Integer categoryId,
            Integer languageId,
            String search,
            Boolean onlyPracticed,
            Boolean onlyWeak,
            Pageable pageable
    );

    ResponseEntity<UserWordListResponse> save(WordRequest request);
    ResponseEntity<UserWordListResponse> unsave(Long wordId);

}
