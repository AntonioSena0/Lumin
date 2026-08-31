package br.com.api.controller;

import br.com.api.dto.response.HomeSummaryResponse;
import br.com.api.service.HomeSummaryService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/lumin/users/{userId}/home")
@AllArgsConstructor
public class HomeSummaryControllerImpl implements HomeSummaryController {

    private final HomeSummaryService service;

    @Override
    @GetMapping
    public ResponseEntity<HomeSummaryResponse> findByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(service.findByUserId(userId));
    }
}
