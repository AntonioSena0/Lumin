package br.com.api.service;

import br.com.api.dto.response.ProfileSummaryResponse;

public interface ProfileSummaryService {

    ProfileSummaryResponse findByUserId(Long userId);

}
