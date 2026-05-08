package br.com.api.service;

import br.com.api.entity.User;

import java.util.List;

public interface UserService {

    List<User> findAll();
    User findById(Long id);
    User create(User request);

}
