package br.com.api.controller;

import br.com.api.dto.response.ProfileSummaryResponse;
import org.springframework.http.ResponseEntity;

public interface ProfileSummaryController {

    ResponseEntity<ProfileSummaryResponse> findByUserId(Long userId);

}
