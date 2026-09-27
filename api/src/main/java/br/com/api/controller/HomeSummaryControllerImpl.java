package br.com.api.controller;

import br.com.api.dto.response.HomeSummaryResponse;
import br.com.api.service.HomeSummaryService;
import br.com.api.util.SecurityUtils;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/lumin/me/home")
@AllArgsConstructor
public class HomeSummaryControllerImpl implements HomeSummaryController {

    private final HomeSummaryService service;

    @Override
    @GetMapping
    public ResponseEntity<HomeSummaryResponse> findByUserId() {
        return ResponseEntity.ok(service.findByUserId(SecurityUtils.currentUserId()));
    }
}
