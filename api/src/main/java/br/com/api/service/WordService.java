package br.com.api.service;

import br.com.api.dto.request.WordRequest;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.dto.response.WordResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface WordService {

    Page<WordResponse> findAll(Pageable pageable);
    WordResponse findById(Long wordId);
    Page<WordResponse> search(String q, Integer languageId, Pageable pageable);
    UserWordListResponse save(WordRequest request, Long userId);
    UserWordListResponse unsave(Long wordId, Long userId);

}
