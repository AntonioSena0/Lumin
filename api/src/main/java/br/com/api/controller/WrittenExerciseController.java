package br.com.api.controller;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.WrittenExerciseCheckResponse;
import br.com.api.dto.response.WrittenExerciseResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

public interface WrittenExerciseController {

    ResponseEntity<List<WrittenExerciseResponse>> findByUserId(Long userId);
    ResponseEntity<WrittenExerciseResponse> generate(Long userId, Long wordId);
    ResponseEntity<WrittenExerciseCheckResponse> check(Long id, ExerciseCheckRequest answer);
    ResponseEntity<Void> delete(Long id);

}
