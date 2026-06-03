package br.com.api.controller;

import br.com.api.dto.response.StudySessionResponse;
import br.com.api.service.StudySessionService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("lumin/sessions")
@AllArgsConstructor
public class StudySessionControllerImpl implements StudySessionController{

    private final StudySessionService service;

    @Override
    @GetMapping("/{id}")
    public ResponseEntity<StudySessionResponse> findById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @Override
    @PostMapping("/create/{userId}/{wordId}")
    public ResponseEntity<StudySessionResponse> startSession(@PathVariable Long userId, @PathVariable Long wordId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.startSession(userId, wordId));
    }

    @Override
    @PatchMapping("/finish/{id}")
    public ResponseEntity<StudySessionResponse> finishSession(@PathVariable Long id) {
        return ResponseEntity.ok(service.finishSession(id));
    }
}
