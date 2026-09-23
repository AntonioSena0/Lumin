package br.com.api.controller;

import br.com.api.dto.request.PlacementTestSubmitRequest;
import br.com.api.dto.response.PlacementQuestionResponse;
import br.com.api.dto.response.PlacementTestResultResponse;
import br.com.api.service.PlacementQuestionService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lumin/placement-test")
@AllArgsConstructor
public class PlacementQuestionControllerImpl implements PlacementQuestionController {

    private PlacementQuestionService service;

    @Override
    @GetMapping("/languages/{languageId}")
    public ResponseEntity<List<PlacementQuestionResponse>> findByLanguageId(@PathVariable Integer languageId) {
        return ResponseEntity.ok(service.findByLanguage(languageId));
    }

    @Override
    @PostMapping("/users/{userId}/languages/{languageId}/submit")
    public ResponseEntity<PlacementTestResultResponse> submit(@PathVariable Long userId, @PathVariable Integer languageId, @RequestBody PlacementTestSubmitRequest request) {
        return ResponseEntity.ok(service.submit(userId, languageId, request));
    }

}
