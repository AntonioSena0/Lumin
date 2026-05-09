package br.com.api.service;

import br.com.api.dto.LanguageResponse;
import br.com.api.mapper.LanguageMapper;
import br.com.api.repository.LanguageRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class LanguageServiceImpl implements LanguageService{

    private final LanguageRepository repository;

    @Override
    public List<LanguageResponse> findAll() {
        return repository.findAll()
                .stream()
                .map(LanguageMapper::toLanguageResponse)
                .toList();
    }

    @Override
    public LanguageResponse findById(Integer id) {
        return LanguageMapper.toLanguageResponse(repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Língua não encontrada")));
    }

}
