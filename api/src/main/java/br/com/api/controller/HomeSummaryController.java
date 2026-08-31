package br.com.api.controller;


import br.com.api.dto.response.HomeSummaryResponse;
import org.springframework.http.ResponseEntity;

public interface HomeSummaryController {

    ResponseEntity<HomeSummaryResponse> findByUserId(Long userId);

}
