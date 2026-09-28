package br.com.api.service;

import br.com.api.domain.VoiceType;
import br.com.api.dto.request.AvatarChangeRequest;
import br.com.api.dto.request.UserPutRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.UserMeResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.dto.request.UserPatchRequest;
import br.com.api.entity.Avatar;
import br.com.api.entity.Language;
import br.com.api.entity.Setting;
import br.com.api.entity.User;
import br.com.api.exception.ConflictException;
import br.com.api.exception.NotFoundException;
import br.com.api.mapper.UserMapper;
import br.com.api.repository.AvatarRepository;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.SettingRepository;
import br.com.api.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService{

    private final UserRepository repository;
    private final LanguageRepository languageRepository;
    private final AvatarRepository avatarRepository;
    private final SettingRepository settingRepository;
    private final PasswordEncoder passwordEncoder;
    private final VerificationCodeServiceImpl verificationCodeService;

    @Override
    public Page<UserResponse> findAll(Pageable pageable) {
        return repository.findAllWithRelations(pageable)
                .map(UserMapper::toUserResponse);
    }

    @Override
    public UserResponse findById(Long id) {

        return UserMapper.toUserResponse(
                repository.findByIdWithRelations(id)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"))
        );

    }

    @Override
    public UserMeResponse findMe(Long id) {
        return UserMapper.toUserMeResponse(
                repository.findByIdWithRelations(id)
                        .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"))
        );
    }

    @Override
    @Transactional
    public UserMeResponse create(UserRequest request) {

        if(repository.findByName(request.name()).isPresent()){
            throw new ConflictException();
        }

        if(repository.findByEmail(request.email()).isPresent()){
            throw new ConflictException();
        }

        Language nativeLanguage = languageRepository.findById(request.nativeLanguage())
                .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua nativa não encontrada"));

        Language chosenLanguage = languageRepository.findById(request.chosenLanguage())
                .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua escolhida para tradução não encontrada"));

        Avatar avatar = avatarRepository.findById(1)
                .orElseThrow(() -> new NotFoundException("AVATAR_NOT_FOUND", "Erro ao criar usuário"));

        String hashPassword = passwordEncoder.encode(request.password());

        User savedUser = repository.save(UserMapper.toUser(request, hashPassword, nativeLanguage, chosenLanguage, avatar));

        settingRepository.save(Setting
            .builder()
            .user(savedUser)
            .appLanguage(nativeLanguage)
            .notifyDaily(true)
            .notifyReview(true)
            .voice(VoiceType.FEMALE)
            .build());

        return UserMapper.toUserMeResponse(savedUser);

    }

    @Override
    @Transactional
    public UserMeResponse update(Long id, UserPutRequest request){

        User existingUser = repository.findByIdWithRelations(id)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"));

        if(repository.existsByNameAndIdNot(request.name(), id)){
            throw new ConflictException();
        }

        if(repository.existsByEmailAndIdNot(request.email(), id)){
            throw new ConflictException();
        }

        existingUser.setName(request.name());
        if (!request.email().equals(existingUser.getEmail())) {
            verificationCodeService.revoke(existingUser.getEmail());
            existingUser.setEmail(request.email());
            existingUser.setEmailVerified(false);
            verificationCodeService.issue(request.email(), request.name());
        }
        existingUser.setPassword(passwordEncoder.encode(request.password()));

        Language nativeLanguage = languageRepository.findById(request.nativeLanguage())
                .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua nativa não encontrada"));

        existingUser.setNativeLanguage(nativeLanguage);

        Language chosenLanguage = languageRepository.findById(request.chosenLanguage())
                .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua escolhida para tradução não encontrada"));

        existingUser.setChosenLanguage(chosenLanguage);

        return UserMapper.toUserMeResponse(existingUser);

    }

    @Override
    @Transactional
    public UserMeResponse parcialUpdate(Long id, UserPatchRequest request){

        User existingUser = repository.findByIdWithRelations(id)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"));

        if(request.name() != null){
            if(repository.existsByNameAndIdNot(request.name(), id)){
                throw new ConflictException();
            }
            existingUser.setName(request.name());
        }

        if(request.email() != null && !request.email().equals(existingUser.getEmail())){
            if(repository.existsByEmailAndIdNot(request.email(), id)){
                throw new ConflictException();
            }
            verificationCodeService.revoke(existingUser.getEmail());
            existingUser.setEmail(request.email());
            existingUser.setEmailVerified(false);
            verificationCodeService.issue(request.email(), existingUser.getName());
        }

        if(request.password() != null){
            existingUser.setPassword(passwordEncoder.encode(request.password()));
        }

        if(request.nativeLanguage() != null){
            Language language = languageRepository.findById(request.nativeLanguage())
                    .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua nativa não encontrada"));

            existingUser.setNativeLanguage(language);
        }

        if(request.chosenLanguage() != null){
            Language language = languageRepository.findById(request.chosenLanguage())
                    .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua escolhida para tradução não encontrada"));

            existingUser.setChosenLanguage(language);
        }

        return UserMapper.toUserMeResponse(existingUser);

    }

    @Override
    @Transactional
    public UserMeResponse changeAvatar(Long id, AvatarChangeRequest request) {

        Avatar avatar = avatarRepository.findById(request.avatarId())
                .orElseThrow(() -> new NotFoundException("AVATAR_NOT_FOUND", "Avatar não encontrado"));

        User existingUser = repository.findByIdWithRelations(id)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"));

        if(existingUser.getAvatar().getId().equals(avatar.getId())){
            return UserMapper.toUserMeResponse(existingUser);
        }

        existingUser.setAvatar(avatar);

        return UserMapper.toUserMeResponse(existingUser);
    }

    @Override
    @Transactional
    public void delete(Long id){

        if(!repository.existsById(id)){
            throw new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado");
        }

        repository.deleteById(id);

    }

}
