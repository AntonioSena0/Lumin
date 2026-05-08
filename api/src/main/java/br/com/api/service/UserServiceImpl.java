package br.com.api.service;

import br.com.api.entity.User;
import br.com.api.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService{

    private final UserRepository repository;

    @Override
    public List<User> findAll() {
        return repository.findAll();
    }

    @Override
    public User findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
    }

    @Override
    public User create(User request) {

        if(repository.findByName(request.getName()).isPresent()){
            throw new RuntimeException("Nome de usuário já cadastrado");
        }

        if(repository.findByEmail(request.getEmail()).isPresent()){
            throw new RuntimeException("Credenciais Inválidas");
        }

        return repository.save(request);

    }
}
