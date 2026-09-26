package br.com.api.service;

import br.com.api.dto.request.SettingUpdateRequest;
import br.com.api.dto.response.SettingResponse;

public interface SettingService {

    SettingResponse findByUserId(Long userId);
    SettingResponse updateByUserId(SettingUpdateRequest request, Long userId);

}
