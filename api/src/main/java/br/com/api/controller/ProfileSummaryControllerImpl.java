package br.com.api.controller;

import br.com.api.dto.response.ProfileSummaryResponse;
import br.com.api.service.ProfileSummaryService;
import br.com.api.util.SecurityUtils;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/lumin/me/profile")
@AllArgsConstructor
public class ProfileSummaryControllerImpl implements ProfileSummaryController{

    private final ProfileSummaryService service;

    @Override
    @GetMapping
    public ResponseEntity<ProfileSummaryResponse> findByUserId() {
        return ResponseEntity.ok(service.findByUserId(SecurityUtils.currentUserId()));
    }
}
