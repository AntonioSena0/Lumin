package br.com.api.controller;

import br.com.api.dto.request.SettingUpdateRequest;
import br.com.api.dto.response.SettingResponse;
import br.com.api.service.SettingService;
import br.com.api.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/lumin/me/settings")
@AllArgsConstructor
public class SettingControllerImpl implements SettingController{

    private final SettingService service;

    @Override
    @GetMapping
    public ResponseEntity<SettingResponse> findByUserId() {
        return ResponseEntity.ok(service.findByUserId(SecurityUtils.currentUserId()));
    }

    @Override
    @PatchMapping
    public ResponseEntity<SettingResponse> updateSettings(@RequestBody @Valid SettingUpdateRequest request) {
        return ResponseEntity.ok(service.updateByUserId(request, SecurityUtils.currentUserId()));
    }

}
