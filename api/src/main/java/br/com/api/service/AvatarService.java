package br.com.api.service;

import br.com.api.dto.response.AvatarResponse;

import java.util.List;

public interface AvatarService {

    List<AvatarResponse> findAll();
    AvatarResponse findById(Integer id);

}
