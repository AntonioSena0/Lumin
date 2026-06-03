package br.com.api.service;

import br.com.api.dto.response.StudySessionResponse;

import java.util.List;

public interface StudySessionService {

    StudySessionResponse findById(Long id);
    StudySessionResponse startSession(Long userId, Long wordId);
    StudySessionResponse finishSession(Long id);

}
