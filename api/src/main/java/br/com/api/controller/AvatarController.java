package br.com.api.controller;

import br.com.api.dto.response.AvatarResponse;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface AvatarController {

    ResponseEntity<List<AvatarResponse>> findAll();
    ResponseEntity<AvatarResponse> findById(Integer id);

}
