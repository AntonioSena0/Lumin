package br.com.api.service;

import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserUpdateRequest;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import br.com.api.mapper.UserMapper;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService{

    private final UserRepository repository;
    private final LanguageRepository languageRepository;

    @Override
    public List<UserResponse> findAll() {
        return repository.findAll()
                .stream()
                .map(UserMapper::toUserResponse)
                .toList();
    }

    @Override
    public UserResponse findById(Long id) {

        return UserMapper.toUserResponse(
                repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"))
        );

    }

    @Override
    public UserResponse create(UserRequest request) {

        if(repository.findByName(request.name()).isPresent()){
            throw new RuntimeException("Nome de usuário já cadastrado");
        }

        if(repository.findByEmail(request.name()).isPresent()){
            throw new RuntimeException("Verifique os dados informados");
        }

        Language nativeLanguage = languageRepository.findById(request.nativeLanguage())
                .orElseThrow(() -> new RuntimeException("Língua nativa não encontrada"));

        Language chosenLanguage = languageRepository.findById(request.chosenLanguage())
                .orElseThrow(() -> new RuntimeException("Língua escolhida para tradução não encontrada"));

        return UserMapper.toUserResponse(repository.save(UserMapper.toUser(request, nativeLanguage, chosenLanguage)));

    }

    @Override
    public UserResponse update(Long id, UserUpdateRequest request){

        User existingUser = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        if(repository.existsByNameAndIdNot(request.name(), id)){
            throw new RuntimeException("Nome de usuário já cadastrado");
        }

        if(repository.existsByEmailAndIdNot(request.email(), id)){
            throw new RuntimeException("Verifique os dados informados");
        }

        existingUser.setName(request.name());
        existingUser.setEmail(request.email());
        existingUser.setPassword(request.password());

        Language nativeLanguage = languageRepository.findById(request.nativeLanguage())
                .orElseThrow(() -> new RuntimeException("Língua nativa não encontrada"));

        existingUser.setNativeLanguage(nativeLanguage);

        Language chosenLanguage = languageRepository.findById(request.chosenLanguage())
                .orElseThrow(() -> new RuntimeException("Língua escolhida para tradução não encontrada"));

        existingUser.setChosenLanguage(chosenLanguage);

        return UserMapper.toUserResponse(repository.save(existingUser));

    }

    @Override
    public UserResponse parcialUpdate(Long id, UserUpdateRequest request){

        User existingUser = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        if(request.name() != null){
            if(repository.existsByNameAndIdNot(request.name(), id)){
                throw new RuntimeException("Nome de Usuário já cadastrado");
            }
            existingUser.setName(request.name());
        }

        if(request.email() != null){
            if(repository.existsByEmailAndIdNot(request.email(), id)){
                throw new RuntimeException("Verifique os dados informados");
            }
            existingUser.setEmail(request.email());
        }

        if(request.password() != null){
            existingUser.setPassword(request.password());
        }

        if(request.nativeLanguage() != null){
            Language language = languageRepository.findById(request.nativeLanguage())
                    .orElseThrow(() -> new RuntimeException("Língua nativa não encontrada"));

            existingUser.setNativeLanguage(language);
        }

        if(request.chosenLanguage() != null){
            Language language = languageRepository.findById(request.chosenLanguage())
                    .orElseThrow(() -> new RuntimeException("Língua escolhida para tradução não encontrada"));

            existingUser.setChosenLanguage(language);
        }

        return UserMapper.toUserResponse(repository.save(existingUser));

    }

    @Override
    public void delete(Long id){

        User existingUser = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        repository.deleteById(id);

    }

}
