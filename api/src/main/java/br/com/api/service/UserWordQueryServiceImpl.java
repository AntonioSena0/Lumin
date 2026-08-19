package br.com.api.service;

import br.com.api.dto.request.UserWordFilterRequest;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.mapper.UserWordMapper;
import br.com.api.repository.UserWordRepository;
import br.com.api.specification.UserWordSpecification;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;


@Service
@AllArgsConstructor
public class UserWordQueryServiceImpl implements UserWordQueryService {

    private final UserWordRepository repository;

    @Override
    public UserWordListResponse findUserWordById(Long userId, Long wordId) {
        return UserWordMapper.toUserWordListResponse(repository.findByUserIdAndWordIdWithRelations(userId, wordId)
                .orElseThrow(() -> new RuntimeException("Detalhes não encontrados")));
    }

    @Override
    public Page<UserWordListResponse> findUserWords(Long userId, UserWordFilterRequest filter, Pageable pageable) {
        return repository.findAll(UserWordSpecification.withFilters(userId, filter), pageable)
                .map(UserWordMapper::toUserWordListResponse);
    }

}
