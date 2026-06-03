package br.com.api.controller;

import br.com.api.dto.response.StudySessionResponse;
import org.springframework.http.ResponseEntity;

public interface StudySessionController {

    ResponseEntity<StudySessionResponse> findById(Long id);
    ResponseEntity<StudySessionResponse> startSession(Long userId, Long wordId);
    ResponseEntity<StudySessionResponse> finishSession(Long id);

}
