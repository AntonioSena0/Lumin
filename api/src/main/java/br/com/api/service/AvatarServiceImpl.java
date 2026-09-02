package br.com.api.service;

import br.com.api.dto.response.AvatarResponse;
import br.com.api.mapper.AvatarMapper;
import br.com.api.repository.AvatarRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class AvatarServiceImpl implements AvatarService {

    private final AvatarRepository repository;

    @Override
    public List<AvatarResponse> findAll() {
        return repository.findAll()
                .stream()
                .map(AvatarMapper::toAvatarResponse)
                .toList();
    }

    @Override
    public AvatarResponse findById(Integer id) {
        return AvatarMapper.toAvatarResponse(repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Avatar não encontrado")));
    }
}
