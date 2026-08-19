package br.com.api.service;

import br.com.api.dto.request.UserWordFilterRequest;
import br.com.api.dto.response.UserWordListResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;


public interface UserWordQueryService {

    UserWordListResponse findUserWordById(Long userId, Long wordId);
    Page<UserWordListResponse> findUserWords(Long userId, UserWordFilterRequest filter, Pageable pageable);

}