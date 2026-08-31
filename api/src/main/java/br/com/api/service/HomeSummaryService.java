package br.com.api.service;

import br.com.api.dto.response.HomeSummaryResponse;

public interface HomeSummaryService {

    HomeSummaryResponse findByUserId(Long userId);

}
