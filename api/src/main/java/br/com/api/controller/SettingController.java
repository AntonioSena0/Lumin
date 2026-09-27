package br.com.api.controller;

import br.com.api.dto.request.SettingUpdateRequest;
import br.com.api.dto.response.SettingResponse;
import org.springframework.http.ResponseEntity;

public interface SettingController {

    ResponseEntity<SettingResponse> findByUserId();
    ResponseEntity<SettingResponse> updateSettings(SettingUpdateRequest request);

}
